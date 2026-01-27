# frozen_string_literal: true

require "rails_helper"

module Hmrc
  RSpec.describe IdempotencyGuard do
    subject(:guard) { described_class.new }

    let(:utr)   { "1234567890" }
    let(:ixbrl) { "<ixbrl>payload</ixbrl>" }

    describe "#call" do
      context "when no prior submission attempt exists" do
        it "creates a pending submission attempt and returns Success" do
          result = guard.call(ixbrl:, utr:)

          expect(result).to be_success

          attempt = result.value!
          expect(attempt).to be_pending
          expect(attempt.utr).to eq(utr)
          expect(attempt.submission_key).to be_present
        end
      end

      context "when a pending submission attempt already exists" do
        let!(:attempt) { guard.call(ixbrl:, utr:).value! }

        it "returns Success with the existing attempt" do
          result = guard.call(ixbrl:, utr:)

          expect(result).to be_failure
          expect(result.failure[:type]).to eq(:duplicate_submission_in_flight)
        end
      end

      context "when a failed submission attempt exists" do
        let!(:attempt) do
          guard.call(ixbrl:, utr:).value!.tap do |a|
            a.update!(status: :failed)
          end
        end

        it "resets the attempt to pending and returns Success" do
          result = guard.call(ixbrl:, utr:)

          expect(result).to be_success

          attempt.reload
          expect(attempt).to be_pending
        end
      end

      context "when the submission has already been submitted" do
        let!(:attempt) do
          guard.call(ixbrl:, utr:).value!.tap do |a|
            a.update!(
              status: :submitted,
              hmrc_reference: "ABC123"
            )
          end
        end

        it "returns a Failure to short-circuit the operation" do
          result = guard.call(ixbrl:, utr:)

          expect(result).to be_failure
          expect(result.failure[:type]).to eq(:already_submitted)
          expect(result.failure[:hmrc_reference]).to eq("ABC123")
        end
      end
    end
  end
end
