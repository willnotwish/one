# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ct600::SubmitReturnOperation do
  subject(:operation) { described_class.new }

  let(:ixbrl) { "<ixbrl>valid</ixbrl>" }
  let(:utr)   { "1234567890" }

  let(:attempt) { FactoryBot.create(:hmrc_submission_attempt, status: :pending, utr:) }

  let(:oauth_token) { instance_double("Hmrc::OauthToken") }

  let(:raw_hmrc_response) do
    {
      status: 200,
      body: "<Response><ReceiptID>ABC123456789</ReceiptID></Response>"
    }
  end

  let(:parsed_response) do
    {
      status: 200,
      hmrc_reference: "ABC123456789",
      body: "<Response><ReceiptID>ABC123456789</ReceiptID></Response>"
    }
  end

  before do
    # Idempotency
    allow(Hmrc::IdempotencyGuard)
      .to receive(:new)
      .and_return(instance_double(Hmrc::IdempotencyGuard, call: Dry::Monads::Result::Success.new(attempt)))

    # OAuth
    allow(operation)
      .to receive(:request_oauth_token)
      .and_return(Dry::Monads::Result::Success.new(oauth_token))

    # Submission
    allow(operation)
      .to receive(:post_hmrc_request)
      .and_return(Dry::Monads::Result::Success.new(raw_hmrc_response))

    # Parsing
    allow(Hmrc::SubmissionResponseParser)
      .to receive(:new)
      .and_return(
        instance_double(
          Hmrc::SubmissionResponseParser,
          call: Dry::Monads::Result::Success.new(parsed_response)
        )
      )

    # Outcome recording
    allow(Hmrc::SubmissionOutcomeRecorder)
      .to receive(:new)
      .and_return(
        instance_double(
          Hmrc::SubmissionOutcomeRecorder,
          call: Dry::Monads::Result::Success.new(parsed_response)
        )
      )
  end

  describe "#call" do
    it "returns Success with the parsed response" do
      result = operation.call(ixbrl:, utr:)

      expect(result).to be_success
      expect(result.value!).to eq(parsed_response)
    end

    it "marks the submission attempt as submitted" do
      operation.call(ixbrl:, utr:)

      attempt.reload
      expect(attempt.status).to eq("submitted"),
        "expected submitted, got #{attempt.status.inspect} (#{attempt.attributes.inspect})"

      # expect(attempt).to be_submitted
      # expect(attempt.hmrc_reference).to eq("ABC123456789")
      # expect(attempt.submitted_at).to be_present
    end
  end
end
