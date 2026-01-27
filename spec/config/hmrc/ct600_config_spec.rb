# frozen_string_literal: true

require "rails_helper"
require "climate_control"

RSpec.describe Hmrc::Ct600Config do
  describe ".utr" do
    context "with a valid 10-digit CT UTR in ENV" do
      it "returns the UTR" do
        ClimateControl.modify(HMRC_CT600_UTR: "1234567890") do
          expect(described_class.utr).to eq("1234567890")
        end
      end
    end

    context "when the UTR is missing" do
      it "raises a clear error" do
        ClimateControl.modify(HMRC_CT600_UTR: nil) do
          expect {
            described_class.utr
          }.to raise_error(KeyError, /HMRC_CT600_UTR/)
        end
      end
    end

    context "when the UTR is not 10 digits" do
      it "raises an error for short UTRs" do
        ClimateControl.modify(HMRC_CT600_UTR: "12345") do
          expect {
            described_class.utr
          }.to raise_error(RuntimeError, /Invalid CT UTR/)
        end
      end

      it "raises an error for non-numeric UTRs" do
        ClimateControl.modify(HMRC_CT600_UTR: "ABCDEF1234") do
          expect {
            described_class.utr
          }.to raise_error(RuntimeError, /Invalid CT UTR/)
        end
      end
    end
  end
end
