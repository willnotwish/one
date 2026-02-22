# frozen_string_literal: true

module Ct600
  module Ixbrl
    module TaxonomyProfiles
      # Base profile
      class Base
        attr_reader :year

        def initialize(year:)
          @year = year
        end
      end
    end
  end
end
