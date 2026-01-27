# frozen_string_literal: true

module Hmrc
  # Raised when an HMRC submission operation returns a Failure
  # and must be escalated to exception-driven infrastructure
  # (e.g. ActiveJob / Sidekiq retries).
  class SubmissionFailedError < StandardError
    attr_reader :failure

    def initialize(failure)
      @failure = failure
      super(build_message(failure))
    end

    private

    def build_message(failure)
      "HMRC submission failed: #{failure.inspect}"
    end
  end
end
