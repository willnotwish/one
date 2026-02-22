require 'rails_helper'

module Hmrc
  RSpec.describe SubmissionAttempt, type: :model do
    subject(:attempt) do
      described_class.new(
        submission_key: 'abc123',
        utr: '1111222233'
      )
    end

    describe 'validations' do
      it 'is valid with required attributes' do
        expect(attempt).to be_valid
      end

      it 'requires a submission_key' do
        attempt.submission_key = nil
        expect(attempt).not_to be_valid
      end

      it 'requires a utr' do
        attempt.utr = nil
        expect(attempt).not_to be_valid
      end

      it 'enforces uniqueness of submission_key' do
        described_class.create!(
          submission_key: 'abc123',
          utr: '1111222233'
        )

        expect(attempt).not_to be_valid
      end
    end

    describe 'enum backing' do
      it 'stores status as an integer' do
        attempt.save!
        expect(attempt.read_attribute_before_type_cast(:status)).to be_an(Integer)
      end

      it 'defaults to pending' do
        attempt.save!
        expect(attempt).to be_pending
      end
    end

    describe 'state machine' do
      let(:hmrc_reference) { 'HMRC123' }

      before { attempt.save! }

      it 'starts in the pending state' do
        expect(attempt.aasm.current_state).to eq(:pending)
      end

      context 'when marking as submitted' do
        it 'transitions from pending to submitted' do
          attempt.mark_submitted!(hmrc_reference:)

          expect(attempt).to be_submitted
          expect(attempt).to be_complete
          expect(attempt.hmrc_reference).to eq(hmrc_reference)
          expect(attempt.completed_at).to be_within(1.second).of(Time.now)
        end
      end

      context 'when marking as failed' do
        let(:failure_type) { 'fooey type' }
        let(:failure_status) { 400 }
        let(:failure_body) { '<Error>Rejected</Error>' }

        it 'transitions from pending to failed' do
          attempt.mark_failed!(failure_type:, failure_status:, failure_body:)
          expect(attempt).to be_failed
          expect(attempt).to be_complete
          expect(attempt.hmrc_reference).to be_nil
          expect(attempt.failure_type).to eq(failure_type)
          expect(attempt.failure_status).to eq(failure_status)
          expect(attempt.failure_body).to eq(failure_body)
          expect(attempt.completed_at).to be_within(1.second).of(Time.now)
        end
      end

      context 'invalid transitions' do
        let(:failure_type) { 'fooey type' }
        let(:failure_status) { 400 }
        let(:failure_body) { 'bar' }

        it 'does not allow marking submitted from failed' do
          attempt.mark_failed!(failure_type:, failure_status:, failure_body:)
          expect { attempt.mark_submitted!(hmrc_reference:) }.to raise_error(AASM::InvalidTransition)
        end
      end
    end

    describe 'notification' do
      let(:utr) { "1234567890" }
      let(:ixbrl) { "<ixbrl>valid</ixbrl>" }
      let(:submission_key) { Digest::SHA256.hexdigest(ixbrl) }

      it "calls the notifier when marked submitted" do
        fake_instance = double("Notifier instance", call: true)
        fake_class = double("Notifier class", new: fake_instance)

        # stub the class-level notifier_class to return our fake class
        allow(described_class).to receive(:notifier_class).and_return(fake_class)

        expect(fake_instance).to receive(:call).with(attempt)

        attempt.mark_submitted!(hmrc_reference: "HMRC123")
      end

      it "calls the notifier when marked failed" do
        fake_instance = double("Notifier instance", call: true)
        fake_class = double("Notifier class", new: fake_instance)

        # stub the class-level notifier_class to return our fake class
        allow(described_class).to receive(:notifier_class).and_return(fake_class)

        expect(fake_instance).to receive(:call).with(attempt)

        attempt.mark_failed!(
          failure_type: :hmrc_rejected_submission,
          failure_status: 400,
          failure_body: "<Error>Rejected</Error>"
        )
      end

      it "calls the notifier when marked awaiting_manual_resolution" do
        fake_instance = double("Notifier instance", call: true)
        fake_class = double("Notifier class", new: fake_instance)

        # stub the class-level notifier_class to return our fake class
        allow(described_class).to receive(:notifier_class).and_return(fake_class)

        expect(fake_instance).to receive(:call).with(attempt)

        attempt.mark_awaiting_manual_resolution!
      end
    end
  end
end
