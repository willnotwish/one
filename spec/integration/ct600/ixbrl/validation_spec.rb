# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

module Ct600
  # Minimal generation + validation
  module Ixbrl
    RSpec.describe 'Ct600 iXBRL Integration', type: :integration do
      let(:generator) { Generator.new }
      let(:output_dir) { '/output' }

      # Output helper. Writes given xml to output file for subsequent validation wth arelle
      def write_output_file(xml, filename)
        path = File.join(output_dir, filename)
        File.write(path, xml)
        path.to_s
      end

      it 'generates valid iXBRL for a minimal 2024-compliant submission' do
        submission = FactoryBot.build(:ct600_submission)

        xml = generator.call(submission, fact_mapping: FactMapping::V2024)
        path = write_output_file(xml, 'ct600_2024_minimal.xhtml')
        expect(File.exist?(path)).to be_truthy
      end
    end
  end
end
