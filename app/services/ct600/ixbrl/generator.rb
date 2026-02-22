# frozen_string_literal: true

# app/services/ct600/ixbrl/generator.rb
module Ct600
  module Ixbrl
    # Generates compatible XML from a given submission definition
    class Generator
      # submission: Ct600::Submission instance (previously validated) containing figures, company & period
      # rendering_context: versioned fact mapping and taxonomy profile
      def call(submission, rendering_context:)
        fact_mapping = rendering_context.fact_mapping
        taxonomy_profile = rendering_context.taxonomy_profile
  
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          build_doctype(xml)

          xml.html(Namespaces.html_attributes) do
            xml.head { xml.title('CT600 iXBRL') }

            xml.body do
              xml.div(style: 'display:none') do
                xml['ix'].header do
                  xml['ix'].references do
                    fact_mapping_schema_refs(xml:, taxonomy_paths: taxonomy_profile.schema_hrefs)
                  end

                  xml['ix'].resources do
                    build_contexts(xml:, company: submission.company, period: submission.period, fact_mapping:)
                    build_units(xml:, fact_mapping:)
                  end
                end
              end

              build_facts(xml:, submission:, fact_mapping:)
            end
          end
        end.to_xml
      end

      private

      def build_doctype(xml)
        # Required to generate <!DOCTYPE html> without quotes
        xml.doc.create_internal_subset('html', nil, nil)
      end

      def build_contexts(xml:, company:, period:, fact_mapping:, builder: Nodes::Context.new)
        fact_mapping
          .values
          .map(&:context_ref)
          .uniq
          .map { |name| Contexts.context_for(name) }
          .each { |context_spec| builder.call(xml:, company:, period:, **context_spec ) }
      end

      def build_facts(xml:, submission:, fact_mapping:, builder: Nodes::Fact.new)
        fact_mapping.values.each do |spec|
          value = extract_value(submission:, spec:)
          builder.call(xml:, spec:, value:)
        end
      end

      def build_units(xml:, fact_mapping:, builder: Nodes::Unit.new)
        fact_mapping
          .values
          .map(&:unit_ref)
          .compact
          .uniq
          .each { |unit_ref| builder.call(xml:, id: unit_ref, measure: Units.measure_for(unit_ref)) }
      end

      def fact_mapping_schema_refs(xml:, taxonomy_paths:)
        taxonomy_paths.each do |local_path|
          xml['link'].schemaRef(
            'xlink:type' => 'simple',
            'xlink:href' => local_path
          )
        end
      end

      def extract_value(submission:, spec:)
        source_object =
          case spec.source
          when :company    then submission.company
          when :period     then submission.period
          when :figures    then submission.figures
          when :submission then submission
          else
            raise "Unknown source #{spec.source}"
          end

        source_object.public_send(spec.source_attribute)
      end
    end
  end
end
