# frozen_string_literal: true

# app/services/ct600/ixbrl/facts_from_figures.rb
module Ct600
  module Ixbrl
    module Mappings
      class FactsFromFigures
        def call(figures, fact_mapping:, **opts)
          fact_mapping.map do |attr, spec|
            new_fact(spec:, value: figures[attr], **opts)
          end
        end

        private

        def new_fact(spec:, value:, context_ref: 'ctx', unit_ref: 'GBP', decimals: '0')
          Fact.new(
            name: spec[:element],
            namespace: spec[:namespace],
            value:,
            context_ref:,
            unit_ref:,
            decimals:
          )
        end
      end
    end
  end
end
