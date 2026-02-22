# frozen_string_literal: true

module Hmrc
  module Submissions
    # A service to act as an adapter between a Dry::Monads::Result returned by an HMRC submission operation:
    # - and a successful value, or
    # - a raised domain exception which may trigger a retry (eg, from a background job).
    #
    # The boundary between
    # - functional, monadic domain code
    # - exception-driven infrastructure (ActiveJob / Sidekiq)
    #
    # | Status code / range | Meaning                  | How to handle                                                              | Retryable?                                                              |
    # | ------------------- | ------------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
    # | **2xx (200-299)**   | Success                  | Submission accepted by HMRC                                                | No                                                                      |
    # | **4xx (400-499)**   | Client error / rejection | Usually indicates a **rejected submission** (bad data, UTR mismatch, etc.) | No — record the outcome, don't retry                                    |
    # | **429**             | Too Many Requests        | Rate-limiting; client should wait and retry                                | Yes — can retry after `Retry-After` if provided, or exponential backoff |
    # | **5xx (500-599)**   | Server error             | Temporary HMRC problem                                                     | Yes — retry later, usually exponential backoff                          |
    # | **3xx (300-399)**   | Redirect                 | Unlikely in an API context; generally unexpected                           | Treat as **unexpected error** — short-circuit, log, investigate         |

    class OutcomeTranslator
      def call(result)
        return if result.success?

        error_from_failed_outcome(result.failure)
      end

      private

      # Errors are retryable or non retryable
      def error_from_failed_outcome(outcome)
        return RetryableSubmissionFailedError.new(outcome.to_h) if retryable?(outcome)

        NonRetryableSubmissionFailedError.new(outcome.to_h)
      end

      def retryable?(outcome)
        case outcome.status
        when 200..299 # BAU
          false
        when 429 # rate limit
          true
        when 400..499 # BAU
          false
        when 500..599
          true
        else
          false
        end
      end
    end
  end
end
