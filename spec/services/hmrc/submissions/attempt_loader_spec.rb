# frozen_string_literal: true

# spec/services/hmrc/submissions/attempt_loader_spec.rb
require "rails_helper"

module Hmrc
  module Submissions
    RSpec.describe AttemptLoader do
      subject(:loader) { described_class.new }

      let(:attempt) { FactoryBot.create(:hmrc_submission_attempt) }
      let(:attempt_id) { attempt.id }

      describe "#call" do
        context "when the attempt exists" do
          it "returns Success with the attempt" do
            result = loader.call(attempt_id: attempt_id)

            expect(result).to be_a(Dry::Monads::Success)
            expect(result.value!).to eq(attempt)
          end
        end

        context "when the attempt does not exist" do
          let(:missing_id) { 999999 }

          it "returns Failure with type :submission_attempt_not_found" do
            result = loader.call(attempt_id: missing_id)

            expect(result).to be_a(Dry::Monads::Failure)
            expect(result.failure[:type]).to eq(:submission_attempt_not_found)
            expect(result.failure[:attempt_id]).to eq(missing_id)
          end
        end

        context "when ActiveRecord raises an error" do
          before do
            allow(SubmissionAttempt).to receive(:find_by)
              .and_raise(ActiveRecord::ActiveRecordError, "DB problem")
          end

          it "returns Failure with type :submission_attempt_load_failed" do
            result = loader.call(attempt_id: attempt_id)

            expect(result).to be_a(Dry::Monads::Failure)
            expect(result.failure[:type]).to eq(:submission_attempt_load_failed)
            expect(result.failure[:attempt_id]).to eq(attempt_id)
            expect(result.failure[:message]).to eq("DB problem")
          end
        end
      end
    end
  end
end
