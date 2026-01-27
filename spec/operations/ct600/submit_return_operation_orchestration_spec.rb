# spec/operations/ct600/submit_return_operation_orchestration_spec.rb
require 'rails_helper'

RSpec.describe Ct600::SubmitReturnOperation, type: :operation do
  include Dry::Monads[:result]

  let(:ixbrl) { "<ixbrl>dummy</ixbrl>" }
  let(:utr)   { "1234567890" }

  let(:attempt) { instance_double(Hmrc::SubmissionAttempt) }
  let(:oauth_token) { "fake-token" }
  let(:raw_hmrc_response) { { status: 200, body: "<Response><ReceiptID>ABC123456789</ReceiptID></Response>" } }
  let(:parsed_response) { { status: 200, hmrc_reference: "ABC123456789", body: raw_hmrc_response[:body] } }

  subject(:operation) { described_class.new }

  before do
    # Idempotency guard
    allow(Hmrc::IdempotencyGuard).to receive(:new)
      .and_return(instance_double(Hmrc::IdempotencyGuard, call: Success(attempt)))

    # OAuth token request
    allow(operation).to receive(:request_oauth_token)
      .and_return(Success(oauth_token))

    # HMRC submission
    allow(operation).to receive(:post_hmrc_request)
      .and_return(Success(raw_hmrc_response))

    # Response parsing
    allow(Hmrc::SubmissionResponseParser).to receive(:new)
      .and_return(instance_double(Hmrc::SubmissionResponseParser, call: Success(parsed_response)))

    # Outcome recording
    allow(Hmrc::SubmissionOutcomeRecorder).to receive(:new)
      .and_return(instance_double(Hmrc::SubmissionOutcomeRecorder, call: Success(parsed_response)))
  end

  it "calls all steps with correct arguments and returns Success" do
    result = operation.call(ixbrl: ixbrl, utr: utr)

    expect(result).to be_a(Dry::Monads::Success)
    expect(result.value!).to eq(parsed_response)
  end

  context "when a step fails" do
    it "short-circuits on idempotency guard failure" do
      allow(Hmrc::IdempotencyGuard).to receive(:new)
        .and_return(instance_double(Hmrc::IdempotencyGuard, call: Failure(type: :duplicate_submission)))

      result = operation.call(ixbrl: ixbrl, utr: utr)

      expect(result).to be_a(Dry::Monads::Failure)
      expect(result.failure[:type]).to eq(:duplicate_submission)
    end

    it "short-circuits on parser failure" do
      allow(Hmrc::SubmissionResponseParser).to receive(:new)
        .and_return(instance_double(Hmrc::SubmissionResponseParser, call: Failure(type: :hmrc_invalid_success_response)))

      result = operation.call(ixbrl: ixbrl, utr: utr)

      expect(result).to be_a(Dry::Monads::Failure)
      expect(result.failure[:type]).to eq(:hmrc_invalid_success_response)
    end

    it "short-circuits on outcome recorder failure" do
      allow(Hmrc::SubmissionOutcomeRecorder).to receive(:new)
        .and_return(instance_double(Hmrc::SubmissionOutcomeRecorder, call: Failure(type: :submission_recording_failed)))

      result = operation.call(ixbrl: ixbrl, utr: utr)

      expect(result).to be_a(Dry::Monads::Failure)
      expect(result.failure[:type]).to eq(:submission_recording_failed)
    end
  end
end
