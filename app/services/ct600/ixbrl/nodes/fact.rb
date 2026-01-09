# frozen_string_literal: true

# app/services/ct600/ixbrl/fact_builder.rb
module Ct600
  module Ixbrl
    module Nodes
      # Generates a <ix:nonFraction> node for the given fact, using the given (Nokogiri) xml context
      class Fact
        def call(fact, xml:)
          xml['ix'].nonFraction(
            name: "#{fact.namespace}:#{fact.name}",
            contextRef: fact.context_ref,
            unitRef: fact.unit_ref,
            decimals: fact.decimals
          ) do
            xml << fact.value.to_s
          end
        end
      end
    end
  end
end
