# spec/services/ct600/ixbrl/context_node_builder_spec.rb
require 'rails_helper'

module Ct600
  module Ixbrl
    module Nodes
      RSpec.describe Unit, type: :ixbrl_node do
        subject(:xml_output) { builder.to_xml }

        let(:builder) do
          Nokogiri::XML::Builder.new do |xml|
            xml.root('xmlns:xbrli' => 'http://www.xbrl.org/2003/instance') do
              described_class.new.call(
                xml: xml,
                id: 'GBP',
                measure: 'iso4217:GBP'
              )
            end
          end
        end

        it 'builds an xbrli:unit node' do
          expect(xml_output).to include('<xbrli:unit')
          expect(xml_output).to include('id="GBP"')
          expect(xml_output).to include('<xbrli:measure>iso4217:GBP</xbrli:measure>')
        end
      end
    end
  end
end
