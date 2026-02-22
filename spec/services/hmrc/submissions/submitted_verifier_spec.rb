# frozen_string_literal: true

# spec/services/hmrc/submissions/submitted_verifier_spec.rb
require "rails_helper"

module Hmrc
  module Submissions
    RSpec.describe SubmittedVerifier do
      subject(:verifier) { described_class.new }

      let(:attempt) { FactoryBot.create(:hmrc_submission_attempt, status: status) }

      describe "#call" do
        context "when the attempt is already submitted" do
          let(:status) { :submitted }

          it "returns Success with the attempt" do
            result = verifier.call(attempt: attempt)

            expect(result).to be_a(Dry::Monads::Success)
            expect(result.value!).to eq(attempt)
          end
        end

        context "when the attempt is not submitted" do
          let(:status) { :pending }

          it "returns Failure with type :invalid_recovery_state" do
            result = verifier.call(attempt: attempt)

            expect(result).to be_a(Dry::Monads::Failure)
            expect(result.failure[:type]).to eq(:invalid_recovery_state)
            expect(result.failure[:reason]).to eq(:submission_not_accepted)
            expect(result.failure[:attempt_id]).to eq(attempt.id)
          end
        end
      end
    end
  end
end
