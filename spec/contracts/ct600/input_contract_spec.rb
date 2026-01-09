# frozen_string_literal: true

# spec/contracts/ct600/input_contract_spec.rb
require 'rails_helper'

module Ct600
  RSpec.describe InputContract do
    let(:contract) { described_class.new }

    let(:valid_params) do
      {
        non_trading_loan_profits: "1000.50",
        profits_before_other_deductions_and_reliefs: "200.55",
        losses_on_unquoted_shares: "50",
        management_expenses: "10.5"
      }
    end

    let(:invalid_params) do
      {
        non_trading_loan_profits: "1000.555",
        profits_before_other_deductions_and_reliefs: "200.555",
        losses_on_unquoted_shares: "50.123",
        management_expenses: "10.555"
      }
    end

    let(:currency_fields) do
      [
        :non_trading_loan_profits,
        :profits_before_other_deductions_and_reliefs,
        :losses_on_unquoted_shares,
        :management_expenses
      ]
    end

    it "passes with decimals ≤ 2" do
      expect(contract.call(valid_params)).to be_success
    end

    it "fails with decimals > 2" do
      result = contract.call(invalid_params)
      expect(result).to be_failure

      currency_fields.each do |field|
        expect(result.errors.to_h[field]).to include(
          'must not have more than 2 decimal places.'
        )
      end
    end
  end
end
