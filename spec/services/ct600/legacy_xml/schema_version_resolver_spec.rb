# frozen_string_literal: true

require "rails_helper"

module Ct600
  module LegacyXml
    RSpec.describe SchemaVersionResolver do
      let(:resolver) { described_class.new }

      # Simple Period struct for testing
      Period = Struct.new(:starts_on, :ends_on)

      describe "#call" do
        it "returns the correct schema for periods before 1 Apr 2024" do
          period = Period.new(Date.new(2023, 1, 1), Date.new(2023, 12, 31))
          result = resolver.call(period: period)
          expect(result).to be_success
          expect(result.value!).to eq("2023-04-01")
        end

        it "returns the 2024 schema for periods ending between 1 Apr 2024 and 31 Mar 2026" do
          period = Period.new(Date.new(2024, 1, 1), Date.new(2025, 2, 28))
          result = resolver.call(period: period)
          expect(result).to be_success
          expect(result.value!).to eq("2024-04-01")
        end

        it "returns the 2026 schema for periods ending on/after 1 Apr 2026" do
          period = Period.new(Date.new(2026, 1, 1), Date.new(2026, 6, 30))
          result = resolver.call(period: period)
          expect(result).to be_success
          expect(result.value!).to eq("2026-04-01")
        end

        it "fails if period ends before earliest known schema" do
          period = Period.new(Date.new(2020, 1, 1), Date.new(2020, 12, 31))
          result = resolver.call(period: period)
          expect(result).to be_failure
          expect(result.failure).to match(/No schema version/)
        end
      end
    end
  end
end
