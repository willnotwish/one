# frozen_string_literal: true

# spec/contracts/ct600/input_contract_spec.rb
require 'rails_helper'

module Ct600
  RSpec.describe InputContract do
    subject(:result) { contract.call(params) }

    let(:contract) { described_class.new }

    let(:metadata) do
      {
        company_name: Faker::Company.name,
        company_number: Faker::Number.leading_zero_number(digits: 8),
        period_starts_on: '2024-04-01',
        period_ends_on: '2025-03-31'
      }
    end

    let(:valid_params) do
      metadata.merge(
        non_trading_loan_profits: "1000.50",
        profits_before_other_deductions_and_reliefs: "200.55",
        losses_on_unquoted_shares: "50",
        management_expenses: "10.5"
      )
    end

    let(:invalid_params) do
      metadata.merge(
        non_trading_loan_profits: "1000.555",
        profits_before_other_deductions_and_reliefs: "200.555",
        losses_on_unquoted_shares: "50.123",
        management_expenses: "10.555"
      )
    end

    let(:currency_fields) do
      %i[
        non_trading_loan_profits
        profits_before_other_deductions_and_reliefs
        losses_on_unquoted_shares
        management_expenses
      ]
    end

    context 'with valid params' do
      let(:params) { valid_params }

      it { is_expected.to be_success }
    end

    describe 'date handling' do
      context 'when a period start date is entered in the form 1/4/2024' do
        let(:params) { valid_params.merge(period_starts_on: '1/4/2024') }

        it 'rejects the date with a user-facing error' do
          expect(result.errors.to_h[:period_starts_on]).to include('must be in the format YYYY-MM-DD (for example 2024-04-01)')
        end
      end

      context 'when the period end date is entered in full text form (March 31st 2025)' do
        let(:params) { valid_params.merge(period_ends_on: 'March 31st 2025') }

        it 'rejects the date with a user-facing error' do
          expect(result.errors.to_h[:period_ends_on]).to include('must be in the format YYYY-MM-DD (for example 2025-03-31)')
        end
      end

      context 'when an ISO-formatted period start date is not a real calendar date' do
        let(:params) do
          valid_params.merge(period_starts_on: '2024-02-30')
        end

        it 'rejects the date with a user-facing error' do
          errors = result.errors.to_h

          expect(errors[:period_starts_on]).to include('must be a valid date')
        end
      end

      context 'when an ISO-formatted period end date is not a real calendar date' do
        let(:params) do
          valid_params.merge(period_ends_on: '2024-02-30')
        end

        it 'rejects the date with a user-facing error' do
          errors = result.errors.to_h

          expect(errors[:period_ends_on]).to include('must be a valid date')
        end
      end
    end

    context 'with invalid params' do
      let(:params) { invalid_params }

      it { is_expected.to be_failure }

      it 'has the correct error messages' do
        currency_fields.each do |field|
          expect(result.errors.to_h[field]).to include(
            'must not have more than 2 decimal places.'
          )
        end
      end
    end

    context 'when the period end is before the period start (a typo, maybe)' do
      let(:params) do
        valid_params.merge(period_starts_on: '2024-04-01', period_ends_on: '2023-03-31')
      end

      it 'picks up the correct error message' do
        errors = result.errors.to_h
        expect(errors[:period_ends_on]).to include('must be after the period start date')
      end
    end
  end
end
