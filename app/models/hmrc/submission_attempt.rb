# frozen_string_literal: true

module Hmrc
  # Persistent record of submission attempts
  class SubmissionAttempt < ApplicationRecord
    include AASM

    validates :submission_key, presence: true, uniqueness: true
    validates :utr, presence: true

    enum :status, { pending: 0, submitted: 1, failed: 2 }

    aasm column: :status, enum: true do
      state :pending, initial: true
      state :submitted
      state :failed

      event :mark_submitted do
        transitions from: :pending, to: :submitted
      end

      event :mark_failed do
        transitions from: :pending, to: :failed
      end

      event :retry do
        transitions from: :failed, to: :pending
      end
    end
  end
end
