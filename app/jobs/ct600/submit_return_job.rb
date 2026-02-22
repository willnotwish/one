# frozen_string_literal: true

module Ct600
  # This job submits a CT600 return (an iXBRL document) relating
  # to a company with a given UTR.
  # 
  # If the outcome is successful (return submitted and the HMRC receipt reference recorded),
  # there's nothing more to do: the job is complete. This is the happy path.
  # 
  # If a permanent (non-retryable) error (for example submission is invalid/buggy) is encountered
  # then the job will not be rescheduled because it will never succeed.
  # 
  # If a temporary (retryable) error (for example network failure/HMRC server down) occurs,
  # the job will be retried a maximum of 10 times before giving up permanently.
  #
  # An important edge case is where the submission succeeded and the HMRC receipt
  # reference was returned, but the job failed to persist the reference.
  # We do not want any HMRC resubmission. Instead, a second "recovery" job is scheduled.
  class SubmitReturnJob < ApplicationJob
    queue_as :default

    EXPONENTIAL_BACKOFF = ->(n) { 2**n }

    # Policy for retryable errors
    retry_on(Hmrc::RetryableSubmissionFailedError, wait: EXPONENTIAL_BACKOFF, attempts: 10) do |job, error|
      args = job.arguments.first
      job.handle_retry_exhausted(error, **args)
    end

    # Policy for permanent errors is to discard
    discard_on Hmrc::NonRetryableSubmissionFailedError

    def logger
      Rails.logger
    end

    def perform(ixbrl:, utr:)
      outcome = SubmitReturnOperation.new.call(ixbrl:, utr:)
      logger.info("CT600 submission outcome: #{outcome.inspect}, utr: #{utr}")
      handle(outcome)
    end

    def handle_retry_exhausted(error, ixbrl:, utr:)
      attempt = Hmrc::SubmissionAttempt.find_by(utr: utr)
      logger.error("#{self.class.name} failed for UTR: #{utr} after #{executions} attempts. Submission attempt id: #{attempt.id}. Error: #{error}")

      attempt.mark_awaiting_manual_resolution!
    end

    private

    def handle(outcome)
      case outcome
      in Dry::Monads::Failure(type: :already_submitted, hmrc_reference: hmrc_reference)
        logger.info("Already submitted: #{hmrc_reference}")

      in Dry::Monads::Failure(type: :permanent_failure)
        logger.warn("Permanent failure for UTR #{utr}")
      
      in Dry::Monads::Failure(type: :submission_recording_failed, **data)
        logger.error("Failed to record outcome: #{data.inspect}")
        RecoverSubmissionOutcomeJob.perform_later(**data)

      else
        # Default is to translate the outcome into an exception for job control
        translator = Hmrc::Submissions::OutcomeTranslator.new
        translator.call(outcome).tap { |error| raise error if error }
      end
    end
  end
end
