# spec/services/submission_outcome_notifier_spec.rb
require "rails_helper"

module Hmrc
  module Submissions
    RSpec.describe OutcomeNotifier do
      subject(:call) { described_class.new.call(attempt) }

      let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

      context 'when the attempt is submitted' do
        let(:attempt) { FactoryBot.build(:hmrc_submission_attempt, status: :submitted, hmrc_reference: 'HMRC123') }

        it 'sends a submission succeeded email asynchronously' do
          expect(UserMailer)
            .to receive(:ct600_submission_succeeded)
            .with(attempt)
            .and_return(mailer)

          expect(mailer).to receive(:deliver_later)

          call

          expect(attempt.submitted?).to be true
        end
      end

      context 'when the attempt has failed' do
        let(:attempt) { FactoryBot.build(:hmrc_submission_attempt, status: :failed, failure_type: :hmrc_rejected_submission) }

        it 'sends a submission failed email asynchronously' do
          expect(UserMailer)
            .to receive(:ct600_submission_failed)
            .with(attempt)
            .and_return(mailer)

          expect(mailer).to receive(:deliver_later)

          call

          expect(attempt.failed?).to be_truthy
        end
      end
    end
  end
end