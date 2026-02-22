# frozen_string_literal: true

require 'rails_helper'

module Ct600
  module Ixbrl
    # Taxonomy profiles
    module TaxonomyProfiles
      RSpec.describe Arelle do
        subject(:profile) { described_class.new(year: 2026) }

        describe '#schema_hrefs' do
          it 'returns root-scoped schema paths' do
            expect(profile.schema_hrefs).to eq(
              [
                '/taxonomies/FRC-2026-Taxonomy-v1.0.0/FRS-102/2026-01-01/FRS-102-2026-01-01.xsd',
                '/taxonomies/HMRC-CT-2014-v1-994/CT-2014-v1-994.xsd',
                '/taxonomies/arelle-shims/ct/shim-2026.xsd'
              ]
            )
          end
        end
      end
    end
  end
end
