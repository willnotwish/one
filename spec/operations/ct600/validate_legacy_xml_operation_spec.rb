# frozen_string_literal: true

require 'rails_helper'

# Ct600
module Ct600
  RSpec.describe ValidateLegacyXmlOperation do
    let(:operation) { described_class.new }

    let(:valid_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <CT600 xmlns="http://www.hmrc.gov.uk/xml">
          <CompanyName>Test Ltd</CompanyName>
        </CT600>
      XML
    end

    let(:invalid_xml) { '<CT600><CompanyName>Missing closing tag' }

    let(:period) { FactoryBot.build(:ct600_period) } # Use the factory

    describe '#call' do
      context 'when XML is valid against the schema' do
        it 'returns a successful validation result' do
          result = operation.call(xml: valid_xml, period: period)

          expect(result).to be_success
          expect(result.value!).to have_attributes(valid?: true)
        end
      end

      context 'when XML is malformed' do
        it 'raises Nokogiri::XML::SyntaxError' do
          expect do
            operation.call(xml: invalid_xml, period: period)
          end.to raise_error(Nokogiri::XML::SyntaxError)
        end
      end

      context 'when XML does not conform to the schema' do
        it 'returns a failure with errors' do
          xml_missing_required = <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <CT600 xmlns="http://www.hmrc.gov.uk/xml"/>
          XML

          result = operation.call(xml: xml_missing_required, period: period)
          expect(result).to be_failure
          expect(result.failure.errors).to include(a_string_matching(/element/))
        end
      end
    end
  end
end
