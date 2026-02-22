# frozen_string_literal: true

module Hmrc
  module Submissions
    class SubmittedVerifier
      include Dry::Monads[:result]

      def call(attempt:)
        return Success(attempt) if attempt.submitted?

        Failure(
          type: :invalid_recovery_state,
          reason: :submission_not_accepted,
          attempt_id: attempt.id
        )
      end
    end
  end
end
