# frozen_string_literal: true

# app/services/ct600/ixbrl/generator.rb
module Ct600
  module Ixbrl
    # Generates compatible XML from a given submission definition
    class Generator
      LOCAL_TAXONOMY_PATHS = {
        frs: 'taxonomies/FRC-2026-Taxonomy-v1.0.0/FRS-102/2026-01-01/FRS-102-2026-01-01.xsd',
        ct: 'taxonomies/HMRC-CT-2014-v1-994/CT-2014-v1-994.xsd'
      }

      # submission: Ct600::Submission instance (previously validated) containing figures, company & period
      # fact_mapping: versioned fact mapping (e.g., FactMapping::V2024)
      # opts: any optional args, e.g., context/unit refs
      def call(submission, fact_mapping:, **opts)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          build_doctype(xml)

          xml.html(Namespaces.html_attributes) do
            xml.head { xml.title('CT600 iXBRL') }

            xml.body do
              xml.div(style: 'display:none') do
                xml['ix'].header do
                  xml['ix'].references do
                    fact_mapping_schema_refs(xml, taxonomy_paths: LOCAL_TAXONOMY_PATHS.values, **opts)
                  end

                  xml['ix'].resources do
                    Nodes::Context
                      .new
                      .call(xml: xml, company: submission.company, period: submission.period, id: 'ctx')

                    Nodes::Unit
                      .new
                      .call(xml: xml, id: 'GBP', measure: 'iso4217:GBP')
                  end
                end
              end

              fact_builder = Nodes::Fact.new

              Mappings::FactsFromFigures
                .new
                .call(submission.figures, fact_mapping: fact_mapping, **opts)
                .each do |fact|
                  fact_builder.call(fact, xml: xml)
                end
            end
          end
        end.to_xml
      end

      private

      def build_doctype(xml)
        # Required to generate <!DOCTYPE html> without quotes
        xml.doc.create_internal_subset('html', nil, nil)
      end

      def fact_mapping_schema_refs(xml, taxonomy_paths:, **)
        taxonomy_paths.each do |local_path|
          xml['link'].schemaRef(
            'xlink:type' => 'simple',
            'xlink:href' => local_path
          )
        end
      end
    end
  end
end
