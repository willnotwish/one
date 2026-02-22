# frozen_string_literal: true

module Ct600
  class RecoverSubmissionOutcomeJob < ApplicationJob
    queue_as :default

    retry_on ActiveRecord::ActiveRecordError,
             wait: :exponentially_longer,
             attempts: 10

    def perform(attempt_id:, parsed_response:)
      operation = RecoverSubmissionOutcomeOperation.new
      operation.call(attempt_id:, parsed_response:)
    end
  end
end
