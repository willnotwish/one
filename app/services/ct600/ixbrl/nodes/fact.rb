# frozen_string_literal: true

module Ct600
  module Ixbrl
    module Nodes
      # Generates a <ix:nonFraction> node for the given fact, using the given (Nokogiri) xml context
      class Fact
        def call(xml:, spec:, value:)
          raise "Missing value for #{spec.name}" if value.nil?

          attrs = build_attrs(spec)

          xml['ix'].send(spec.ix_element_name, **attrs) do
            xml << value.to_s
          end
        end

        private

        # Computes the attributes hash locally from the FactSpecification
        def build_attrs(spec)
          context_id = Contexts.context_for(spec.context_ref)[:id] # registry lookup

          attrs = {
            name: spec.qname,
            contextRef: context_id
          }

          if spec.type == :non_fraction
            attrs[:unitRef] = spec.unit_ref if spec.unit_ref
            attrs[:decimals] = spec.decimals if spec.decimals
          end

          attrs
        end

        # Determines the XML element name based on fact type
        def ix_element_name(spec)
          case spec.type
          when :non_fraction then 'nonFraction'
          when :non_numeric  then 'nonNumeric'
          else
            raise ArgumentError, "Unknown fact type: #{spec.type.inspect}"
          end
        end
      end
    end
  end
end
