# frozen_string_literal: true

module Hmrc
  # Indicates a failure that should be retried by background processing
  class RetryableSubmissionFailedError < SubmissionFailedError
  end
end
