# frozen_string_literal: true

module Ct600
  class SubmitReturnJob < ApplicationJob
    queue_as :default

    retry_on Hmrc::RetryableSubmissionFailedError,
            wait: :exponentially_longer,
            attempts: 10

    discard_on Hmrc::NonRetryableSubmissionFailedError

    def perform(ixbrl:, utr:)
      result = SubmitReturnOperation.new.call(ixbrl:, utr:)
      Hmrc::SubmissionResultHandler.new.call(result)
    end
  end
end
