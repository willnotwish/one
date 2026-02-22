# frozen_string_literal: true

module Ct600
  module Ixbrl
    #  A rendering context instructs the ixbrl generator how (schema hrefs) and what (xbrl facts) to render
    class RenderingContext < Dry::Struct
      attribute :year, Types::Integer
      attribute :fact_mapping,
                Types::Hash.map(Types::Symbol, Types.Instance(FactSpecification))
      attribute :taxonomy_profile, Types.Instance(TaxonomyProfiles::Base)

      # attribute? :mode, Types::Symbol
    end
  end
end
