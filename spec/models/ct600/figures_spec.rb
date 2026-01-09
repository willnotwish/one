# frozen_string_literal: true

require 'rails_helper'

# Test Ct600::Figures
module Ct600
  RSpec.describe Figures, type: :ct600_immutable_struct do
    subject(:figures) { described_class.new }

    it 'exposes the expected attributes' do
      expect(figures.to_h.keys).to contain_exactly(
        :non_trading_loan_profits_and_gains,
        :profits_before_other_deductions_and_reliefs,
        :losses_on_unquoted_shares,
        :management_expenses
      )
    end

    it 'defaults numeric values to zero' do
      expect(figures.management_expenses).to eq(0)
    end

    it 'rejects invalid types' do
      expect do
        described_class.new(management_expenses: '20')
      end.to raise_error(Dry::Struct::Error)
    end
  end
end
