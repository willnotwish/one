# frozen_string_literal: true

require 'rails_helper'

# Test Ct600::Period
module Ct600
  RSpec.describe Period, type: :ct600_immutable_struct do
    subject(:period) do
      described_class.new(starts_on:, ends_on:)
    end

    let(:starts_on) { 1.year.ago.to_date }
    let(:ends_on) { Date.today }

    it 'exposes the expected attributes' do
      expect(period.to_h.keys).to contain_exactly(
        :starts_on,
        :ends_on
      )
    end

    it 'rejects invalid types' do
      expect do
        described_class.new(starts_on: '20', ends_on: '21')
      end.to raise_error(Dry::Struct::Error)
    end
  end
end
