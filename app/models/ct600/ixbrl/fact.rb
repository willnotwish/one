# frozen_string_literal: true

module Ct600
  module Ixbrl
    # Immutable, minimal iXBRL fact node representation. Just enough data to render iXBRL later
    class Fact < Dry::Struct
      attribute :name,        Types::String
      attribute :namespace,   Types::String
      attribute :value,       Types::Integer # an integer
      attribute :context_ref, Types::String # placeholder for now
      attribute :unit_ref,    Types::String # placeholder for now
      attribute :decimals,    Types::String
    end
  end
end
