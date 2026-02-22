# frozen_string_literal: true

require "rails_helper"

module Ct600
  RSpec.describe BuildReturnOperation do
    subject(:operation) { described_class.new }

    let(:metadata) do
      {
        company_name: Faker::Company.name,
        company_number: Faker::Number.leading_zero_number(digits: 8),
        period_starts_on: '2024-04-01',
        period_ends_on: '2025-03-31'
      }
    end

    let(:params) do
      metadata.merge(
        non_trading_loan_profits: '100.00',
        profits_before_other_deductions_and_reliefs: '100.00',
        losses_on_unquoted_shares: '0',
        management_expenses: '10.00'
      )
    end

    describe '#call' do
      context 'when all steps succeed' do
        it 'returns Success(ixbrl)' do
          result = operation.call(params:)

          expect(result).to be_a(Dry::Monads::Result::Success)

          # Whatever your GenerateIxbrl returns — string, hash, object
          expect(result.value!).to be_present
        end
      end

      context 'when input validation fails' do
        let(:params) do
          super().merge(
            management_expenses: '9999.99' # deliberately invalid
          )
        end

        it 'returns Failure from validate_input and short-circuits' do
          result = operation.call(params:)

          expect(result).to be_a(Dry::Monads::Result::Failure)

          failure = result.failure

          # This is important: failure should be contract errors
          expect(failure).to be_a(Hash)
          expect(failure).to have_key(:management_expenses)
        end
      end

      context 'when HMRC validation fails' do
        let(:params) do
          metadata.merge(
            non_trading_loan_profits: '100.00',
            profits_before_other_deductions_and_reliefs: '50.00',
            losses_on_unquoted_shares: '0',
            management_expenses: '60.00' # violates hmrc9167
          )
        end

        it 'returns Failure from validate_hmrc_submission' do
          result = operation.call(params:)

          expect(result).to be_failure

          failure = result.failure
          expect(failure).to be_a(Hash)
          expect(failure).to have_key(:management_expenses)
        end
      end
    end
  end
end
