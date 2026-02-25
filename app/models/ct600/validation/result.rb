# frozen_string_literal: true

module Ct600
  module Validation
    # Generic value object describing a validation result.
    # Applicable whatever the type of object being validated.
    class Result < Dry::Struct
      attribute :valid, Types::Bool
      attribute :errors, Types::Array.of(Types::String).default([].freeze)
      attribute :warnings, Types::Array.of(Types::String).default([].freeze)
      attribute? :duration, Types::Integer

      def valid?
        valid
      end

      def invalid?
        !valid
      end
    end
  end
end