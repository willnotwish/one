# frozen_string_literal: true

# Singe-responsibility service intended for use as a monadic operation step
module Hmrc
  module Submissions
    # Examines the supplied parsed response from HMRC.
    # Marks the attempt as submitted if HMRC accepted it.
    # Marks the attempt as failed if HMRC rejected it or reference is missing.
    # Monadic - returns a Success or Failure monad as appropriate
    class OutcomeRecorder
      include Dry::Monads[:result]

      def call(outcome:, attempt:)
        case outcome
        when Outcomes::Accepted
          attempt.mark_submitted!(hmrc_reference: outcome.hmrc_reference)
        when Outcomes::Rejected
          attempt.mark_failed!(
            failure_type: :hmrc_rejected_submission,
            failure_status: outcome.status,
            failure_body: outcome.body
          )
        end
        Success(outcome)
      rescue ActiveRecord::ActiveRecordError => e
        Failure(type: :submission_recording_failed, message: e.message, original: outcome)
      end
    end
  end
end

# status_code = parsed_response[:status]
# hmrc_reference = parsed_response[:hmrc_reference]
# response_type = parsed_response[:type]

# if response_type == :hmrc_accepted_submission && hmrc_reference.present?
#   attempt.mark_submitted!(hmrc_reference:)
#   Success(parsed_response)
# elsif response_type == :hmrc_rejected_submission
#   attempt.mark_failed!(
#     failure_type: :hmrc_rejected_submission,
#     failure_status: status_code,
#     failure_body: parsed_response[:body]
#   )
#   Failure(parsed_response)
# end
