# spec/operations/ct600/submit_return_operation_spec.rb
require "rails_helper"

module Ct600
  RSpec.describe SubmitReturnOperation do
    let(:ixbrl) { "<ixbrl/>" }
    let(:utr)   { "1234567890" }

    let(:attempt) { Hmrc::SubmissionAttempt.new(submission_key: "abc123", utr: utr) }
    let(:raw_response) { { status: 200, body: "<ReceiptID>HMRC123</ReceiptID>" } }
    let(:parsed_response) { { status: 200, hmrc_reference: "HMRC123", body: raw_response[:body] } }

    # Service doubles
    let(:idempotency_guard) do
      instance_double(Hmrc::Submissions::IdempotencyGuard, call: Dry::Monads::Result::Success.new(attempt))
    end

    let(:oauth_client) do
      instance_double(Hmrc::OauthApiClient, call: Dry::Monads::Result::Success.new("fake-token"))
    end

    let(:submission_client) do
      instance_double(Hmrc::Ct600::SubmissionApiClient, call: Dry::Monads::Result::Success.new(raw_response))
    end

    let(:response_parser) do
      instance_double(Hmrc::Submissions::ResponseParser, call: Dry::Monads::Result::Success.new(parsed_response))
    end

    let(:outcome_recorder) do
      instance_double(Hmrc::Submissions::OutcomeRecorder, call: Dry::Monads::Result::Success.new(parsed_response))
    end

    subject(:operation) do
      SubmitReturnOperation.new(
        idempotency_guard: idempotency_guard,
        oauth_client: oauth_client,
        submission_client: submission_client,
        response_parser: response_parser,
        outcome_recorder: outcome_recorder
      )
    end

    let(:stdout_logger) do
      ActiveSupport::TaggedLogging.new(Logger.new($stdout))
                                  .tap { |logger| logger.level = Logger::DEBUG }
    end

    before do
      Rails.logger = stdout_logger
    end

    it "orchestrates all steps and returns Success with the parsed response" do
      result = operation.call(ixbrl:, utr:)

      expect(result).to be_a(Dry::Monads::Success)
      expect(result.value!).to eq(parsed_response)
    end

    it "calls all services with correct arguments in order" do
      expect(idempotency_guard).to receive(:call).with(ixbrl:, utr:)
      expect(oauth_client).to receive(:call)
      expect(submission_client).to receive(:call).with(ixbrl:, oauth_token: "fake-token", utr:)
      expect(response_parser).to receive(:call).with(ixbrl:, raw_hmrc_response: raw_response)
      expect(outcome_recorder).to receive(:call).with(parsed_response:, attempt:)

      operation.call(ixbrl:, utr:)
    end

    context "when HMRC submission succeeds but outcome recording fails" do
      let(:failure_payload) do
        {
          type: :post_external_side_effect_failure,
          step: :record_outcome,
          hmrc_reference: "HMRC123",
          cause: :db_timeout
        }
      end

      let(:outcome_recorder) do
        instance_double(
          Hmrc::Submissions::OutcomeRecorder,
          call: Dry::Monads::Failure(failure_payload)
        )
      end

      it "halts the operation and returns the failure unchanged" do
        result = operation.call(ixbrl:, utr:)

        expect(result).to be_a(Dry::Monads::Failure)
        expect(result.failure).to eq(failure_payload)
      end

      it "does not attempt any further steps after the failure" do
        # Nothing comes after outcome_recorder today,
        # but this protects you if future steps are added.

        expect(idempotency_guard).to receive(:call)
        expect(oauth_client).to receive(:call)
        expect(submission_client).to receive(:call)
        expect(response_parser).to receive(:call)
        expect(outcome_recorder).to receive(:call)

        operation.call(ixbrl:, utr:)
      end
    end
  end
end
