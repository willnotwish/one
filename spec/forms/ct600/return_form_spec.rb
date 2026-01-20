# spec/forms/ct600/submit_return_form_spec.rb
require 'rails_helper'

module Ct600
  RSpec.describe ReturnForm do
    subject(:form) do
      described_class.new(params, operation:)
    end

    let(:params) do
      {
        company_name: 'Foobar Ltd',
        company_number: '01234567',
        period_starts_on: '2024-04-01',
        period_ends_on: '2025-03-31',
        non_trading_loan_profits: '100.50',
        profits_before_other_deductions_and_reliefs: '200.00',
        losses_on_unquoted_shares: '50',
        management_expenses: '10'
      }
    end

    let(:operation) { instance_double(Ct600::SubmitReturnOperation) }

    describe '#submit' do
      context 'when the pipeline succeeds' do
        let(:ixbrl) { '<html>ixbrl</html>' }

        before do
          allow(operation).to receive(:call).and_return(Dry::Monads::Success(ixbrl: ixbrl))
        end

        it 'returns true' do
          expect(form.submit).to eq(true)
        end

        it 'exposes the ixbrl result' do
          form.submit
          expect(form.ixbrl).to eq(ixbrl)
        end

        it 'has no validation errors' do
          form.submit
          expect(form.errors).to be_empty
        end
      end

      context 'when the pipeline fails' do
        let(:failure) do
          {
            period_starts_on: ['must be in YYYY-MM-DD format'],
            management_expenses: ['must not exceed remaining profits']
          }
        end

        before do
          allow(operation).to receive(:call).and_return(Dry::Monads::Failure(failure))
        end

        it 'returns false' do
          expect(form.submit).to eq(false)
        end

        it 'adds errors to the form object' do
          form.submit

          expect(form.errors[:period_starts_on])
            .to include('must be in YYYY-MM-DD format')

          expect(form.errors[:management_expenses])
            .to include('must not exceed remaining profits')
        end

        it 'does not expose ixbrl' do
          form.submit
          expect(form.ixbrl).to be_nil
        end
      end
    end
  end
end
