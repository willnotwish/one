# frozen_string_literal: true

module Hmrc
  # A service to act as an adapter between a Dry::Monads::Result returned by an HMRC submission operation:
  # - and a successful value, or
  # - a raised domain exception which may trigger a retry (eg, from a background job).
  #
  # The boundary between
  # - functional, monadic domain code
  # - exception-driven infrastructure (ActiveJob / Sidekiq)
  #
  class SubmissionResultHandler
    # Raises an error if the result was a failure, otherwise unwraps the success
    def call(result)
      return result.value! if result.success?

      raise error_from_failure(result.failure)
    end

    private

    # Errors are retryable or non retryable
    def error_from_failure(failure)
      return RetryableSubmissionFailedError.new(failure) if retryable?(failure)

      NonRetryableSubmissionFailedError.new(failure)
    end

    RETRYABLE_FAILURE_TYPES = %i[
      oauth_exception
      oauth_http_error
      submission_exception
    ].freeze

    def retryable?(failure)
      return true if RETRYABLE_FAILURE_TYPES.include?(failure[:type])

      # HTTP-level retry logic
      status_code = failure[:status]&.to_i
      status_code && (status_code >= 500 || status_code == 429)
    end
  end
end
