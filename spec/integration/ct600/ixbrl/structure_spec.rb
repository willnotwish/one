# frozen_string_literal: true

require 'rails_helper'

module Ct600
  module Ixbrl
    RSpec.describe 'Ct600 iXBRL Integration', type: :integration do
      let(:generator) { Generator.new }
      let(:rendering_context) { RenderingContextBuilder.new.call(year: 2024, profile: :arelle) }

      it 'generates structurally valid iXBRL for a minimal 2024 submission' do
        submission = FactoryBot.build(:ct600_submission)

        xml = generator.call(submission, rendering_context:)

        doc = Nokogiri::XML(xml)

        # 1. XML is well formed
        expect { Nokogiri::XML(xml, &:strict) }.not_to raise_error

        # 2. Root element
        expect(doc.root.name).to eq('html')

        # 3. Required namespaces present
        namespaces = doc.root.namespaces.values
        expect(namespaces).to include('http://www.xbrl.org/2013/inlineXBRL')
        expect(namespaces).to include('http://www.xbrl.org/2003/instance')

        # 4. Contexts exist
        contexts = doc.xpath('//xbrli:context', doc.root.namespaces)
        expect(contexts).not_to be_empty

        # 5. Units exist (for numeric facts)
        units = doc.xpath('//xbrli:unit', doc.root.namespaces)
        expect(units).not_to be_empty

        # 6. Facts exist
        non_fraction_facts = doc.xpath('//ix:nonFraction', doc.root.namespaces)
        non_numeric_facts  = doc.xpath('//ix:nonNumeric', doc.root.namespaces)

        expect(non_fraction_facts).not_to be_empty
        expect(non_numeric_facts).not_to be_empty

        # 7. Specific fact: EntityDormantTruefalse
        dormant_fact = doc.at_xpath(
          "//ix:nonNumeric[@name='ct:EntityDormantTruefalse']",
          doc.root.namespaces
        )

        expect(dormant_fact).not_to be_nil
        expect(dormant_fact.text).to eq(submission.dormant.to_s)

        # 8. Check at least one numeric fact matches submission figures
        # (adjust to match your minimal factory)
        example_numeric_fact = doc.at_xpath(
          "//ix:nonFraction[@name='ct:ManagementExpenses']",
          doc.root.namespaces
        )

        if example_numeric_fact
          expect(example_numeric_fact['unitRef']).not_to be_nil
          expect(example_numeric_fact['decimals']).not_to be_nil
          expect(example_numeric_fact.text).to eq(
            submission.figures.management_expenses.to_s
          )
        end
      end
    end
  end
end
