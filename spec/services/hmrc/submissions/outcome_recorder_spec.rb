# frozen_string_literal: true

require "rails_helper"

module Hmrc
  module Submissions
    RSpec.describe OutcomeRecorder do
      subject(:recorder) { described_class.new }

      let(:attempt) do
        Hmrc::SubmissionAttempt.create!(
          utr: "1234567890",
          submission_key: "test-key",
          status: :pending
        )
      end

      describe "#call" do
        context "when HMRC accepted the submission" do
          let(:parsed_response) do
            {
              status: 200,
              hmrc_reference: "ABC123456789",
              body: "<ok/>"
            }
          end

          it "marks the attempt as submitted and returns Success" do
            result = recorder.call(parsed_response:, attempt:)

            expect(result).to be_success
            expect(result.value!).to eq(parsed_response)

            attempt.reload
            expect(attempt).to be_submitted
            expect(attempt.hmrc_reference).to eq("ABC123456789")
            expect(attempt.submitted_at).to be_present
          end
        end

        context "when HMRC responds with a non-2xx status" do
          let(:parsed_response) do
            {
              status: 400,
              hmrc_reference: nil,
              body: "<error>Bad Request</error>"
            }
          end

          it "marks the attempt as failed and returns Failure" do
            result = recorder.call(parsed_response:, attempt:)

            expect(result).to be_failure
            expect(result.failure).to eq(parsed_response)

            attempt.reload
            expect(attempt).to be_failed
            expect(attempt.failure_type).to eq("hmrc_rejected_submission")
            expect(attempt.failure_status).to eq(400)
            expect(attempt.failure_body).to eq("<error>Bad Request</error>")
          end
        end

        context "when HMRC returns 2xx but no reference" do
          let(:parsed_response) do
            {
              status: 200,
              hmrc_reference: nil,
              body: "<ok/>"
            }
          end

          it "marks the attempt as failed and returns Failure" do
            result = recorder.call(parsed_response:, attempt:)

            expect(result).to be_failure
            expect(result.failure).to eq(parsed_response)

            attempt.reload
            expect(attempt).to be_failed
            expect(attempt.failure_type).to eq("hmrc_rejected_submission")
          end
        end

        context "when persisting the outcome raises an ActiveRecord error" do
          let(:parsed_response) do
            {
              status: 200,
              hmrc_reference: "ABC123456789",
              body: "<ok/>"
            }
          end

          before do
            allow(attempt).to receive(:update!).and_raise(ActiveRecord::ActiveRecordError, "DB error")
          end

          it "returns a failure indicating submission recording failed" do
            result = recorder.call(parsed_response:, attempt:)

            expect(result).to be_failure
            expect(result.failure).to include(
              type: :submission_recording_failed,
              message: "DB error",
              original: parsed_response
            )
          end
        end
      end
    end
  end
end
