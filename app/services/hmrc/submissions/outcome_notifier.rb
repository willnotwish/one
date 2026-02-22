# frozen_string_literal: true

# Singe-responsibility service intended for use as a monadic operation step
module Hmrc
  module Submissions
    # The notifier's only responsibility is to fan out notifications appropriate to a terminal state.
    # It is not intended to be part of a step and is therefore non monadic.
    # Notification is a fire-and-forget side effect; the return values of #call is undefined.
    class OutcomeNotifier
      def call(attempt)
        return unless terminal_state?(attempt)

        notify_user(attempt)
        notify_ops(attempt)
      end

      private

      def terminal_state?(attempt)
        attempt.submitted? || attempt.failed?
      end

      def notify_user(attempt)
        case attempt.aasm.current_state
        when :submitted
          UserMailer.ct600_submission_succeeded(attempt).deliver_later
        when :failed
          UserMailer.ct600_submission_failed(attempt).deliver_later
        end
      end

      def notify_ops(attempt)
        # no op for now
      end
    end
  end
end
