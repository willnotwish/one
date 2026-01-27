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
      before { attempt.save! }

      it 'starts in the pending state' do
        expect(attempt.aasm.current_state).to eq(:pending)
      end

      context 'when marking as submitted' do
        it 'transitions from pending to submitted' do
          attempt.mark_submitted!
          expect(attempt).to be_submitted
        end
      end

      context 'when marking as failed' do
        it 'transitions from pending to failed' do
          attempt.mark_failed!
          expect(attempt).to be_failed
        end
      end

      context 'when retrying' do
        before { attempt.mark_failed! }

        it 'transitions from failed back to pending' do
          attempt.retry!
          expect(attempt).to be_pending
        end
      end

      context 'invalid transitions' do
        it 'does not allow retry from pending' do
          expect { attempt.retry! }.to raise_error(AASM::InvalidTransition)
        end

        it 'does not allow marking submitted from failed' do
          attempt.mark_failed!
          expect { attempt.mark_submitted! }.to raise_error(AASM::InvalidTransition)
        end
      end
    end
  end
end
