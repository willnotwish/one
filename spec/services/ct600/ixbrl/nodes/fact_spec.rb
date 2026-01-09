require 'rails_helper'

module Ct600
  # XML related
  module Ixbrl
    # A Nodes::Fact emits one <ix:nonFraction> node for the given IXBRL fact
    module Nodes
      RSpec.describe Fact, type: :service do
        subject(:xml) do
          Nokogiri::XML::Builder.new do |xml|
            xml.html(Namespaces.html_attributes) do
              xml.body do
                described_class.new.call(ixbrl_fact, xml: xml)
              end
            end
          end.to_xml
        end

        let(:ixbrl_fact) { FactoryBot.build(:ct600_ixbrl_fact) }

        it 'emits a valid ix:nonFraction node' do
          expect(xml).to include('<ix:nonFraction')
          expect(xml).to include('name="ct:ManagementExpenses"')
          expect(xml).to include('contextRef="ctx"')
          expect(xml).to include('unitRef="GBP"')
          expect(xml).to include('decimals="0"')
          expect(xml).to include('>20<')
        end
      end
    end
  end
end
