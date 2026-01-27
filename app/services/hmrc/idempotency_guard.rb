# app/services/hmrc/ensure_idempotency.rb
# frozen_string_literal: true

module Hmrc
  # Service that enforces idempotency for HMRC submissions.
  # It ensures that a given payload + UTR combination is only submitted once.
  # Returns a Dry::Monads::Result (Success or Failure) so it can be used directly
  # as a step in an operation pipeline.
  class IdempotencyGuard
    include Dry::Monads[:result]

    def call(**opts)
      attempt = find_or_initialize_attempt(**opts)

      if attempt.new_record?
        attempt.status = :pending
        attempt.save!
        return Success(attempt)
      end

      return Failure(type: :already_submitted, hmrc_reference: attempt.hmrc_reference) if attempt.submitted?
      return Failure(type: :duplicate_submission_in_flight) if attempt.pending?

      if attempt.failed?
        attempt.pending!
        return Success(attempt)
      end

      Failure(type: :unknown_submission_state, status: attempt.status)
    end

    private

    def find_or_initialize_attempt(ixbrl:, utr:, **)
      submission_key = Digest::SHA256.hexdigest(ixbrl)
      SubmissionAttempt.lock.find_or_initialize_by(submission_key: submission_key, utr: utr)
    end
  end
end
