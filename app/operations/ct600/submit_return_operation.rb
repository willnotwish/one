# frozen_string_literal: true

# app/operations/ct600/submit_return_operation.rb
module Ct600
  # ROP pipeline to submit valid iXBRL relating to a given CT600 UTR to HMRC
  class SubmitReturnOperation < ApplicationOperation
    Import = Dry::AutoInject(Hmrc::ServiceContainer)

    include Import[
      'oauth_client',
      'submission_client',
      'submissions.response_parser',
      'submissions.outcome_recorder',
      'submissions.idempotency_guard'
    ]

    # Submits using a sequence of steps - a ROP pipeline.
    # If all steps succeed, it #call returns a results hash wrapped in a Success monad.
    # If a Failure is returned by any step, subsequent steps are skipped and the operation short circuited,
    # returning a Failure to the caller. Callers can inspect or pattern match to extract detailed results.
    def call(ixbrl:, utr:)
      attempt = execute_service_step(
        :ensure_idempotency,
        service: idempotency_guard,
        ixbrl:,
        utr:
      )
      
      oauth_token = execute_service_step(
        :request_oauth_token,
        service: oauth_client
      )
      
      raw_hmrc_response = execute_service_step(
        :post_hmrc_response, 
        service: submission_client,
        ixbrl:,
        oauth_token:,
        utr:
      )

      outcome = execute_service_step(
        :parse_hmrc_response,
        service: response_parser,
        **raw_hmrc_response
      )

      execute_service_step(
        :record_submission_outcome,
        service: outcome_recorder,
        attempt:,
        outcome:
      )

      outcome
    end
  end
end
