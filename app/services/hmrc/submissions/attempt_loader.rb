# frozen_string_literal: true

module Hmrc
  module Submissions
    class AttemptLoader
      include Dry::Monads[:result]

      def call(attempt_id:)
        attempt = SubmissionAttempt.find_by(id: attempt_id)
        return Failure(type: :submission_attempt_not_found, attempt_id: attempt_id) unless attempt

        Success(attempt)

      rescue ActiveRecord::ActiveRecordError => e
        Failure(
          type: :submission_attempt_load_failed,
          attempt_id: attempt_id,
          message: e.message
        )
      end
    end
  end
end
