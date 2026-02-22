# frozen_string_literal: true

module Ct600
  module Ixbrl
    # Purely functional service to build rendering contexts needed for ixbrl generation.
    # Profile choices are arelle/sandbox/production:
    #   - arelle is used for local validation
    #   - sandbox for HMRC validation via their sandbox, and
    #   - production for actual HMRC submission.
    class RenderingContextBuilder
      PROFILES = %i[arelle sandbox production].freeze

      def call(year:, profile:)
        taxonomy_profile =
          case profile.to_sym
          when :arelle
            TaxonomyProfiles::Arelle.new(year:)
          when :sandbox, :production
            TaxonomyProfiles::Hmrc.new(year:)
          else
            raise ArgumentError, "Unknown profile: #{profile}"
          end
        
        fact_mapping = FactMapping.for_year(year)

        RenderingContext.new(year:, taxonomy_profile:, fact_mapping:)
      end
    end
  end
end
