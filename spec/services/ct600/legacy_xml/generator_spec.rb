# frozen_string_literal: true

require "rails_helper"

module Ct600
  module LegacyXml
    RSpec.describe Generator do
      let(:generator) { described_class.new }

      describe '#call' do
        let(:company) { FactoryBot.build(:ct600_company) } #, utr: '8765432100') }
        let(:period) { FactoryBot.build(:ct600_period, starts_on: Date.new(2025, 1, 1), ends_on: Date.new(2025, 12, 31)) }

        let(:figures) do
          FactoryBot.build(:ct600_figures, 
            non_trading_loan_profits_and_gains: 1000,
            profits_before_other_deductions_and_reliefs: 2000,
            losses_on_unquoted_shares: 300,
            management_expenses: 400
          )
        end

        let(:submission) { FactoryBot.build(:ct600_submission, company:, period:, figures:) }
        let(:schema_version) { '2024-04-01' }
        let(:utr) { '8765432100' }

        before do
          allow(Hmrc::Ct600Config).to receive(:utr).and_return(utr)
        end

        it 'returns XML string with company, period, and figures' do
          xml = generator.call(submission:, schema_version:, utr:)

          expect(xml).to be_a(String)
          expect(xml).to include('CompanyName')
          expect(xml).to include(company.name)
          expect(xml).to include("CompanyNumber")
          expect(xml).to include(company.number)
          expect(xml).to include("AccountingPeriodStartDate")
          expect(xml).to include("2025-01-01")
          expect(xml).to include("ProfitBeforeTax")
          expect(xml).to include("2000")
          expect(xml).to include("<UTR>#{utr}</UTR>")
        end
      end
    end
  end
end
