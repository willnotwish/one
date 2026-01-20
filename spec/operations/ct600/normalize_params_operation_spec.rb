# frozen_string_literal: true

# spec/operations/ct600/normalize_params_operation_spec.rb

require 'rails_helper'

module Ct600
  RSpec.describe NormalizeParamsOperation do
    subject(:result) { described_class.new.call(params) }

    context 'when params contain Rails multiparam date fields' do
      let(:params) do
        {
          'period_starts_on(1i)' => '2024',
          'period_starts_on(2i)' => '4',
          'period_starts_on(3i)' => '1',
          'period_ends_on(1i)' => '2025',
          'period_ends_on(2i)' => '3',
          'period_ends_on(3i)' => '31',
          other_field: 'ignored'
        }
      end

      it 'returns Success' do
        expect(result).to be_success
      end

      it 'normalizes dates to ISO-8601 strings' do
        value = result.value!

        expect(value[:period_starts_on]).to eq('2024-04-01')
        expect(value[:period_ends_on]).to eq('2025-03-31')
      end

      it 'removes the multiparam keys' do
        value = result.value!

        expect(value.keys).not_to include(
          :'period_starts_on(1i)',
          :'period_starts_on(2i)',
          :'period_starts_on(3i)'
        )
      end

      it 'preserves unrelated params' do
        expect(result.value![:other_field]).to eq('ignored')
      end
    end

    context 'when params already contain ISO date strings' do
      let(:params) do
        {
          period_starts_on: '2024-04-01',
          period_ends_on: '2025-03-31'
        }
      end

      it 'passes params through unchanged' do
        expect(result).to be_success
        expect(result.value!).to eq(params)
      end
    end

    context 'when multiparam date is invalid' do
      let(:params) do
        {
          'period_starts_on(1i)' => '2024',
          'period_starts_on(2i)' => '2',
          'period_starts_on(3i)' => '31' # invalid date
        }
      end

      it 'returns Failure' do
        expect(result).to be_failure
      end

      it 'includes a field-specific error' do
        expect(result.failure).to eq(
          period_starts_on: ['is not a valid date']
        )
      end
    end
  end
end
