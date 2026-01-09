# frozen_string_literal: true

# spec/services/ct600/ixbrl/facts_from_figures_spec.rb
require 'rails_helper'

module Ct600
  module Ixbrl
    module Mappings
      RSpec.describe FactsFromFigures, type: :service do
        subject(:facts) { described_class.new.call(figures, fact_mapping: mapping) }

        # Minimal Dry::Struct for testing
        let(:figures_class) do
          Class.new(Dry::Struct) do
            include Types

            attribute :management_expenses, Types::Integer
            attribute :non_trading_loan_profits_and_gains, Types::Integer
          end
        end

        let(:figures) do
          figures_class.new(
            management_expenses: 20,
            non_trading_loan_profits_and_gains: 100
          )
        end

        let(:mapping) do
          {
            management_expenses: {
              element: 'ManagementExpenses',
              namespace: 'ct'
            },
            non_trading_loan_profits_and_gains: {
              element: 'NonTradingLoanProfitsAndGains',
              namespace: 'ct'
            }
          }
        end

        it 'returns an array of Fact objects' do
          expect(facts).to all(be_a(Ct600::Ixbrl::Fact))
        end

        it 'maps attributes to correct Fact properties' do
          me_fact = facts.find { |f| f.name == 'ManagementExpenses' }
          expect(me_fact.value).to eq 20
          expect(me_fact.namespace).to eq 'ct'

          ntlg_fact = facts.find { |f| f.name == 'NonTradingLoanProfitsAndGains' }
          expect(ntlg_fact.value).to eq 100
          expect(ntlg_fact.namespace).to eq 'ct'
        end
      end
    end
  end
end
