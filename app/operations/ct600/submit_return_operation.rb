# frozen_string_literal: true

# app/operations/ct600/submit_return_operation.rb
module Ct600
  # ROP pipeline to submit valid iXBRL relating to a given CT600 UTR to HMRC
  class SubmitReturnOperation < ApplicationOperation
    # Submits using a sequence of steps - a ROP pipeline.
    # If all steps succeed, it #call returns a results hash wrapped in a Success monad.
    # If a Failure is returned by any step, subsequent steps are skipped and the operation short circuited,
    # returning a Failure to the caller. Callers can inspect or pattern match to extract detailed results.
    def call(ixbrl:, utr:)
      attempt = step_with_logging(:ensure_idempotency) do
        ensure_idempotency(ixbrl:, utr:)
      end

      oauth_token = step_with_logging(:request_oauth_token) do
        request_oauth_token
      end

      raw_hmrc_response = step_with_logging(:post_hmrc_request) do
        post_hmrc_request(ixbrl:, oauth_token:, utr:)
      end

      parsed_response = step_with_logging(:parse_hmrc_response) do
        parse_hmrc_response(ixbrl:, raw_hmrc_response:)
      end

      step_with_logging(:record_submission_outcome) do
        record_submission_outcome(attempt:, parsed_response:)
      end

      parsed_response # gets wrapped in a Success monad by dry-operation
    end

    private

    # Helpers designed to be called as operation steps.
    # All are "monadic" (return Success or Failure) in order to participate in ROP orchestration.

    # Making the operation idempotent prevents duplicate submssions to HMRC.
    # Returning a Failure here means that a successful submission has previously been made.
    def ensure_idempotency(**args)
      service = Hmrc::IdempotencyGuard.new # monadic
      service.call(**args)
    end

    def request_oauth_token
      service = Hmrc::OauthApiClient.new
      service.call      
    end

    def post_hmrc_request(**opts)
      service = Hmrc::Ct600::SubmissionApiClient.new
      service.call(**opts)
    end

    def parse_hmrc_response(ixbrl:, raw_hmrc_response:)
      service = Hmrc::SubmissionResponseParser.new
      service.call(raw_hmrc_response)
    end

    def record_submission_outcome(attempt:, parsed_response:)
      service = Hmrc::SubmissionOutcomeRecorder.new
      service.call(parsed_response:, attempt:)
    end
  end
end
