# frozen_string_literal: true

module Ct600
  module Ixbrl
    # A declarative specification of how a domain attribute maps to an iXBRL fact.
    # Instances are typically created from a validated hash of attributes.
    class FactSpecification < Dry::Struct
      attribute :name,        Types::String
      attribute :namespace,   Types::String
      attribute :type,        Types::Symbol
      attribute :context_ref, Types::Symbol

      SOURCES = %i[figures period company submission].freeze

      # Source: where does the value come from?
      attribute :source, Types::Symbol.enum(*SOURCES)
      attribute :source_attribute, Types::Symbol

      attribute? :unit_ref, Types::Symbol
      attribute? :decimals, Types::Integer

      # Convenience predicates
      def non_numeric?
        type == :non_numeric
      end

      def non_fraction?
        type == :non_fraction
      end

      IXBRL_ELEMENT_MAP = {
        non_fraction: :nonFraction,
        non_numeric: :nonNumeric
      }.freeze

      def ix_element_name
        IXBRL_ELEMENT_MAP[type]
      end

      # Fully qualified concept name (useful for xml generation)
      def qname
        "#{namespace}:#{name}"
      end

      # def attrs_for_ixbrl
      #   attrs = { name: qname, contextRef: context_ref }
      #   attrs[:unitRef] = unit_ref if type == :non_fraction && unit_ref
      #   attrs[:decimals] = decimals if type == :non_fraction && decimals
      #   attrs
      # end

      # Value extracted from source submission
      def extract_value_from_source(submission)
        source_object = case source
                        when :figures then submission.figures
                        when :period then submission.period
                        when :company then submission.company
                        when :submission then submission
                        end

        source_object[source_attribute]
      end
    end
  end
end
