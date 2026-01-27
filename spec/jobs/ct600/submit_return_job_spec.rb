# frozen_string_literal: true

# spec/jobs/ct600/submit_return_job_spec.rb
require 'rails_helper'

module Ct600
  # Tests that SubmitReturnOperation to used correctly to perform the job
  RSpec.describe SubmitReturnJob, type: :job do
    subject(:job) { described_class.new }

    let(:ixbrl) { '<ixbrl>valid</ixbrl>' }
    let(:utr) { '1234567890' }

    let(:operation) { instance_double(SubmitReturnOperation) }

    before do
      allow(SubmitReturnOperation).to receive(:new).and_return(operation)
    end

    describe '#perform' do
      context 'when submission succeeds' do
        let(:operation_result) do
          Dry::Monads::Success(
            status: 200,
            body: '<ok/>'
          )
        end

        it 'calls the operation with ixbrl' do
          expect(operation)
            .to receive(:call)
            .with(ixbrl: ixbrl, utr: utr)
            .and_return(operation_result)

          job.perform(ixbrl:, utr:)
        end
      end


      context 'when submission fails' do
        let(:failure_payload) do
          {
            type: :submission_http_error,
            status: 400,
            body: '<error/>'
          }
        end

        let(:operation_result) do
          Dry::Monads::Failure(failure_payload)
        end

        before do
          allow(operation).to receive(:call).with(ixbrl:, utr:).and_return(operation_result)
          allow(Rails.logger).to receive(:error)
        end

        it 'logs the failure' do
          expect(Rails.logger).to receive(:error).with(failure_payload)

          begin
            job.perform(ixbrl:, utr:)
          rescue SubmissionFailedError
            # swallow
          end
        end

        it 'raises a domain exception to trigger retry' do
          expect {
            job.perform(ixbrl:, utr:)
          }.to raise_error(SubmissionFailedError) do |error|
            expect(error.failure).to eq(failure_payload)
          end
        end
      end
    end
  end
end
