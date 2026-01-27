# frozen_string_literal: true

module Hmrc
  # Indicates that the submission should *not* be retried as-is
  class NonRetryableSubmissionFailedError < SubmissionFailedError
  end
end
