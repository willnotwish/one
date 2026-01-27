# frozen_string_literal: true

# Singe-responsibility service intended for use as a monadic operation step
module Hmrc
  # Examines the supplied parsed response from HMRC.
  # Marks the attempt as submitted if HMRC accepted it.
  # Marks the attempt as failed if HMRC rejected it or reference is missing.
  # Monadic - returns a Success or Failure monad as appropriate
  class SubmissionOutcomeRecorder
    include Dry::Monads[:result]

    def call(parsed_response:, attempt:)
      status_code = parsed_response[:status]
      reference   = parsed_response[:hmrc_reference]

      if status_code.between?(200, 299) && reference.present?
        attempt.update!(
          status: :submitted,
          hmrc_reference: reference,
          submitted_at: Time.current
        )
        Success(parsed_response)
      else
        attempt.update!(
          status: :failed,
          failure_type: :hmrc_rejected_submission,
          failure_status: status_code,
          failure_body: parsed_response[:body]
        )
        Failure(parsed_response)
      end
    rescue ActiveRecord::ActiveRecordError => e
      Failure(type: :submission_recording_failed, message: e.message, original: parsed_response)
    end
  end
end
