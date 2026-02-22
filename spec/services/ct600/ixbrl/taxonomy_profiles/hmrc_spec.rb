# frozen_string_literal: true

require 'rails_helper'

module Ct600
  module Ixbrl
    # Taxonomy profiles
    module TaxonomyProfiles
      RSpec.describe Hmrc do
        subject(:profile) { described_class.new(year: 2026) }

        describe '#schema_hrefs' do
          it 'returns official HTTPS schema URLs' do
            expect(profile.schema_hrefs).to eq(
              [
                'https://xbrl.frc.org.uk/FRS-102/2026-01-01/FRS-102-2026-01-01.xsd',
                'https://www.hmrc.gov.uk/schemas/ct/CT-2014-v1-994.xsd'
              ]
            )
          end
        end
      end
    end
  end
end
