# frozen_string_literal: true

# spec/operations/ct600/recover_submission_outcome_operation_spec.rb
require "rails_helper"

module Ct600
  RSpec.describe RecoverSubmissionOutcomeOperation do
    subject(:operation) do
      described_class.new(attempt_loader:, submitted_verifier:, outcome_recorder:)
    end

    let(:attempt_id) { 42 }
    let(:parsed_response) do
      {
        status: 200,
        hmrc_reference: "HMRC123",
        body: "<ReceiptID>HMRC123</ReceiptID>"
      }
    end

    let(:attempt) { FactoryBot.build_stubbed(:hmrc_submission_attempt) }

    # service doubles
    let(:attempt_loader) do
      instance_double(Hmrc::Submissions::AttemptLoader)
    end
    let(:submitted_verifier) do
      instance_double(Hmrc::Submissions::SubmittedVerifier)
    end
    let(:outcome_recorder) do
      instance_double(Hmrc::Submissions::OutcomeRecorder)
    end

    before do
      allow(attempt_loader).to receive(:call).with(attempt_id:).and_return(Dry::Monads::Success(attempt))
      allow(submitted_verifier).to receive(:call).with(attempt:).and_return(Dry::Monads::Success(attempt))
      allow(outcome_recorder).to receive(:call).with(attempt:, parsed_response:).and_return(Dry::Monads::Success(parsed_response))
    end

    describe "#call" do
      it "orchestrates all steps and returns the attempt on success" do
        result = operation.call(attempt_id:, parsed_response:)

        expect(result.value!).to eq(attempt)
      end

      it "calls all services with the correct arguments in order" do
        expect(attempt_loader).to receive(:call).with(attempt_id:)
        expect(submitted_verifier).to receive(:call).with(attempt:)
        expect(outcome_recorder).to receive(:call).with(attempt:, parsed_response:)

        operation.call(attempt_id:, parsed_response:)
      end

      context "when submission is not verified" do
        before do
          allow(submitted_verifier).to receive(:call).with(attempt:).and_return(
            Dry::Monads::Failure(type: :invalid_recovery_state, attempt_id: attempt.id)
          )
        end

        it "short-circuits and returns the failure" do
          result = operation.call(attempt_id:, parsed_response:)

          expect(result).to be_a(Dry::Monads::Failure)
          expect(result.failure[:type]).to eq(:invalid_recovery_state)
          expect(result.failure[:attempt_id]).to eq(attempt.id)
        end
      end

      context "when outcome_recorder fails" do
        before do
          allow(outcome_recorder).to receive(:call).with(attempt:, parsed_response:).and_return(
            Dry::Monads::Failure(type: :submission_recording_failed, attempt_id: attempt.id)
          )
        end

        it "propagates the failure" do
          result = operation.call(attempt_id:, parsed_response:)

          expect(result).to be_a(Dry::Monads::Failure)
          expect(result.failure[:type]).to eq(:submission_recording_failed)
          expect(result.failure[:attempt_id]).to eq(attempt.id)
        end
      end
    end
  end
end
