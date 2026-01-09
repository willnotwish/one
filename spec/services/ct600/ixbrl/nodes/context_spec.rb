# spec/services/ct600/ixbrl/context_node_builder_spec.rb
require 'rails_helper'

module Ct600
  module Ixbrl
    # Simple context spec
    module Nodes
      RSpec.describe Context, type: :service do
        subject(:xml_output) { builder.to_xml }

        let(:builder) do
          Nokogiri::XML::Builder.new do |xml|
            xml.root('xmlns:xbrli' => 'http://www.xbrl.org/2003/instance') do
              described_class.new.call(
                xml: xml,
                company: company,
                period: period,
                id: 'ctx'
              )
            end
          end
        end

        let(:company) { Company.new(name: Faker::Company.name, number: '01234567') }

        let(:period) do
          Period.new(starts_on: Date.new(2024, 4, 1), ends_on: Date.new(2025, 3, 31))
        end

        it 'creates an xbrli:context element with the given id' do
          expect(xml_output).to include('<xbrli:context id="ctx">')
        end

        it 'includes the company identifier with Companies House scheme' do
          expect(xml_output).to include(
            '<xbrli:identifier scheme="http://www.companieshouse.gov.uk/">01234567</xbrli:identifier>'
          )
        end

        it 'includes a duration period with start and end dates' do
          expect(xml_output).to include('<xbrli:startDate>2024-04-01</xbrli:startDate>')
          expect(xml_output).to include('<xbrli:endDate>2025-03-31</xbrli:endDate>')
        end
      end
    end
  end
end
