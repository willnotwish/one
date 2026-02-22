# frozen_string_literal: true

# app/operations/ct600/submit_return_operation.rb
module Ct600
  # ROP pipeline to recover from nasty error where submission has been accepted by HMRC
  # but we have so far failed to record the fact. Does NOT call HMRC.
  # 1. Loads persisted state
  # 2. Verifies HMRC submission already happened
  # 3. Runs only safe post-submit steps
  class RecoverSubmissionOutcomeOperation < ApplicationOperation
    Import = Dry::AutoInject(Hmrc::ServiceContainer)

    include Import[
      'submissions.attempt_loader',
      'submissions.submitted_verifier',
      'submissions.outcome_recorder'
    ]

    def call(attempt_id:, parsed_response:)
      attempt = execute_service_step(
        :load_attempt,
        service: attempt_loader,
        attempt_id:
      )
      
      execute_service_step(
        :ensure_submitted,
        service: submitted_verifier,
        attempt:
      )

      execute_service_step(
        :record_submission_outcome,
        service: outcome_recorder,
        attempt:,
        parsed_response:
      )

      attempt
    end
  end
end
