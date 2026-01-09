# frozen_string_literal: true

require 'rails_helper'

module Ct600
  module Ixbrl
    RSpec.describe Generator, type: :service do
      subject(:doc) do
        Nokogiri::XML(
          described_class
            .new
            .call(submission, fact_mapping:)
            .to_xml
        )
      end
      
      let(:fact_mapping) { FactMapping::V2024 }

      let(:figures) do
        FactoryBot.build(
          :ct600_figures,
          management_expenses: 20,
          non_trading_loan_profits_and_gains: 100
        )
      end

      let(:submission) { FactoryBot.build(:ct600_submission, figures:) }

      describe 'generated iXBRL document' do
        it 'has an XHTML root element' do
          expect(doc.root.name).to eq('html')
        end

        it 'includes an iXBRL namespace' do
          expect(doc.root.namespaces.values).to include(
            'http://www.xbrl.org/2013/inlineXBRL'
          )
        end

        it 'includes a DOCTYPE' do
          expect(doc.internal_subset).not_to be_nil
          expect(doc.internal_subset.name).to eq('html')
        end

        it 'contains exactly one xbrli:context' do
          contexts = doc.xpath('//xbrli:context', doc.root.namespaces)
          expect(contexts.size).to eq(1)
        end

        it 'contains exactly one xbrli:unit' do
          units = doc.xpath('//xbrli:unit', doc.root.namespaces)
          expect(units.size).to eq(1)
        end

        it 'renders numeric figures as ix:nonFraction facts' do
          facts = doc.xpath('//ix:nonFraction', doc.root.namespaces)

          expect(facts.size).to eq(2)

          names = facts.map { |n| n['name'] }
          values = facts.map(&:text)

          expect(names).to include(
            'ct:ManagementExpenses',
            'ct:NonTradingLoanProfitsAndGains'
          )

          # NG adds whitespace by default
          expect(values.map(&:strip)).to include('20', '100')
        end
      end
    end
  end
end
