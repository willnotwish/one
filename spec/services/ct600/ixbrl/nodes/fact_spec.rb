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
                described_class.new.call(spec: ixbrl_spec, value:, xml: xml)
              end
            end
          end.to_xml
        end

        # let(:ixbrl_fact) { FactoryBot.build(:ct600_ixbrl_fact) }
        let(:ixbrl_spec) do
          FactSpecification.new(
            name: 'ManagementExpenses',
            namespace: 'ct',
            type: :non_fraction,
            context_ref: :ctx,
            unit_ref: :gbp,
            decimals: 0,
            source: :figures,
            source_attribute: :management_expenses
          )
        end

        let(:value) { 20 }

        it 'emits a valid ix:nonFraction node' do
          expect(xml).to include('<ix:nonFraction')
          expect(xml).to include('name="ct:ManagementExpenses"')
          expect(xml).to include('contextRef="ctx"')
          expect(xml).to include('unitRef="gbp"')
          expect(xml).to include('decimals="0"')
          expect(xml).to include('>20<')
        end
      end
    end
  end
end
