# frozen_string_literal: true

require 'rails_helper'

module Ct600
  RSpec.describe SubmitReturnJob, type: :job do
    subject(:job) { described_class.new }

    let(:ixbrl) { '<ixbrl>valid</ixbrl>' }
    let(:utr)   { '1234567890' }

    let(:operation) { instance_double(SubmitReturnOperation) }
    let(:handler)   { instance_double(Hmrc::SubmissionResultHandler) }

    before do
      allow(SubmitReturnOperation).to receive(:new).and_return(operation)
      allow(Hmrc::SubmissionResultHandler).to receive(:new).and_return(handler)
    end

    describe '#perform' do
      context 'when submission succeeds' do
        let(:operation_result) do
          Dry::Monads::Success(status: 200, body: '<ok/>')
        end

        let(:unwrapped_value) do
          { status: 200, body: '<ok/>' }
        end

        before do
          allow(operation)
            .to receive(:call)
            .with(ixbrl: ixbrl, utr: utr)
            .and_return(operation_result)

          allow(handler)
            .to receive(:call)
            .with(operation_result)
            .and_return(unwrapped_value)
        end

        it 'calls the submission operation with ixbrl and utr' do
          job.perform(ixbrl: ixbrl, utr: utr)

          expect(operation).to have_received(:call)
            .with(ixbrl: ixbrl, utr: utr)
        end

        it 'passes the result to the submission result handler' do
          job.perform(ixbrl: ixbrl, utr: utr)

          expect(handler).to have_received(:call)
            .with(operation_result)
        end

        it 'does not raise an error' do
          expect {
            job.perform(ixbrl: ixbrl, utr: utr)
          }.not_to raise_error
        end
      end

      context 'when submission fails with a retryable error' do
        let(:operation_result) do
          Dry::Monads::Failure(type: :submission_exception, message: 'timeout')
        end

        let(:exception) do
          Hmrc::RetryableSubmissionFailedError.new(operation_result.failure)
        end

        before do
          allow(operation)
            .to receive(:call)
            .and_return(operation_result)

          allow(handler)
            .to receive(:call)
            .and_raise(exception)
        end

        it 'raises the retryable submission error' do
          expect {
            job.perform(ixbrl: ixbrl, utr: utr)
          }.to raise_error(Hmrc::RetryableSubmissionFailedError)
        end
      end

      context 'when submission fails with a non-retryable error' do
        let(:operation_result) do
          Dry::Monads::Failure(type: :submission_http_error, status: 400)
        end

        let(:exception) do
          Hmrc::NonRetryableSubmissionFailedError.new(operation_result.failure)
        end

        before do
          allow(operation)
            .to receive(:call)
            .and_return(operation_result)

          allow(handler)
            .to receive(:call)
            .and_raise(exception)
        end

        it 'raises the non-retryable submission error' do
          expect {
            job.perform(ixbrl: ixbrl, utr: utr)
          }.to raise_error(Hmrc::NonRetryableSubmissionFailedError)
        end
      end
    end
  end
end
