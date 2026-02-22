# frozen_string_literal: true

module Hmrc
  module Submissions
    # Service that enforces idempotency for HMRC submissions.
    # It ensures that a given payload + UTR combination is only submitted once.
    # Returns a Dry::Monads::Result (Success or Failure):
    # Success if the guard passes (submission allowed to proceed) or Failure if the guard blocks.
    # Can be used directly as a step in an operation pipeline.
    class IdempotencyGuard
      include Dry::Monads[:result]

      def call(**opts)
        attempt = find_or_initialize_attempt(**opts)

        if attempt.new_record?
          attempt.save! # state is already pending
          return Success(attempt)
        end

        return Failure(type: :already_submitted, hmrc_reference: attempt.hmrc_reference) if attempt.submitted?
        return Failure(type: :permanent_failure) if attempt.failed?

        Success(attempt) # pending is allowed
      end

      private

      def find_or_initialize_attempt(ixbrl:, utr:, **)
        submission_key = Digest::SHA256.hexdigest(ixbrl)
        SubmissionAttempt.lock.find_or_initialize_by(submission_key: submission_key, utr: utr)
      end
    end
  end
end
