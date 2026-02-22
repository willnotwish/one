# frozen_string_literal: true

module Ixbrl
  # Use to validate a raw hash used to specify ixbrl fact mapping
  # prior to building a FactSpecification value object.
  class FactSpecificationContract < Dry::Validation::Contract
    TYPES = %i[non_fraction non_numeric].freeze

    params do
      required(:name).filled(:string)
      required(:namespace).filled(:string)
      required(:type).filled(:symbol, included_in?: TYPES)
      required(:context_ref).filled(:symbol)

      required(:source).filled(:symbol, included_in?: Ct600::Ixbrl::FactSpecification::SOURCES)
      required(:source_attribute).filled(:symbol)

      optional(:unit_ref).maybe(:symbol)
      optional(:decimals).maybe(:integer)
    end

    rule(:type, :unit_ref, :decimals) do
      case values[:type]
      when :non_numeric
        if values[:unit_ref] || values[:decimals]
          key(:type).failure('non_numeric facts must not have unit_ref or decimals')
        end

      when :non_fraction
        key(:unit_ref).failure('non_fraction facts must have unit_ref') unless values[:unit_ref]
        key(:decimals).failure('non_fraction facts must have decimals') unless values[:decimals]
      end
    end
  end
end
