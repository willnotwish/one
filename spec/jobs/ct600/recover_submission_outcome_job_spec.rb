# frozen_string_literal: true

# spec/jobs/ct600/recover_submission_outcome_job_spec.rb
require "rails_helper"

module Ct600
  RSpec.describe RecoverSubmissionOutcomeJob, type: :job do
    subject(:job) { described_class.new }

    let(:attempt_id) { 123 }
    let(:parsed_response) do
      {
        status: 200,
        hmrc_reference: "HMRC123",
        body: "<ReceiptID>HMRC123</ReceiptID>"
      }
    end

    let(:operation) { instance_double(RecoverSubmissionOutcomeOperation) }

    before do
      allow(RecoverSubmissionOutcomeOperation)
        .to receive(:new)
        .and_return(operation)

      allow(operation)
        .to receive(:call)
    end

    describe "#perform" do
      it "calls the recovery operation with attempt_id and parsed_response" do
        expect(operation)
          .to receive(:call)
          .with(attempt_id:, parsed_response:)

        job.perform(attempt_id:, parsed_response:)
      end
    end
  end
end
