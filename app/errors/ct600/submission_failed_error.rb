# frozen_string_literal: true

module Ct600
  # app/errors/ct600/submission_failed_error.rb
  class SubmissionFailedError < StandardError
    attr_reader :failure

    def initialize(failure)
      @failure = failure
      super(build_message)
    end

    def type
      failure.respond_to?(:[]) ? failure[:type] : nil
    end

    def details
      failure.respond_to?(:to_h) ? failure.to_h : failure
    end

    private

    def build_message
      return 'CT600 submission failed' unless failure.respond_to?(:to_h)

      payload = failure.to_h

      [
        'CT600 submission failed',
        ("type=#{payload[:type]}" if payload[:type]),
        ("status=#{payload[:status]}" if payload[:status]),
        ("message=#{payload[:message]}" if payload[:message])
      ].compact.join(' | ')
    end
  end
end
