# frozen_string_literal: true

require 'rails_helper'

module Ct600
  module Ixbrl
    RSpec.describe RenderingContextBuilder do
      it 'builds HMRC profile with correct hrefs' do
        context = described_class.new.call(year: 2026, profile: :production)

        expect(context.taxonomy_profile.schema_hrefs.first)
          .to start_with('https://')
      end
    end
  end
end
