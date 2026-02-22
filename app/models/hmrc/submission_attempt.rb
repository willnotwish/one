# frozen_string_literal: true

module Hmrc
  # Persistent record of submission attempts
  class SubmissionAttempt < ApplicationRecord
    include AASM

    class_attribute :notifier_class, default: Submissions::OutcomeNotifier

    validates :submission_key, presence: true, uniqueness: true
    validates :utr, presence: true

    enum :status, { pending: 0, submitted: 1, failed: 2, awaiting_manual_resolution: 3 }

    aasm column: :status, enum: true do
      state :pending, initial: true
      state :submitted
      state :failed
      state :awaiting_manual_resolution

      # An attempt cannot be marked as submitted without an HMRC reference (timestamp is optional).
      event :mark_submitted do
        transitions from: :pending, to: :submitted, after: :notify

        before do |hmrc_reference:, submitted_at: Time.current|
          self.hmrc_reference = hmrc_reference
          self.completed_at = submitted_at
        end
      end

      event :mark_failed do
        transitions from: :pending, to: :failed, after: :notify

        before do |failure_type:, failure_status:, failure_body:, failed_at: Time.current|
          self.failure_type = failure_type
          self.failure_status = failure_status
          self.failure_body = failure_body
          self.completed_at = failed_at
        end
      end

      event :mark_awaiting_manual_resolution do
        transitions from: :pending, to: :awaiting_manual_resolution, after: :notify
      end
    end

    def complete?
      submitted? || failed?
    end

    def notify
      notifier_class.new.call(self)
    end
  end
end
