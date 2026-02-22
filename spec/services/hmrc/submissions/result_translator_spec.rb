# frozen_string_literal: true

require 'rails_helper'

module Hmrc
  module Submissions
    RSpec.describe ResultTranslator do
      subject(:handler) { described_class.new }

      describe '#call' do
        context 'when the result is Success' do
          let(:value) { { status: 200, body: '<ok/>' } }
          let(:result) { Dry::Monads::Success(value) }

          it 'returns the successful value' do
            expect(handler.call(result)).to eq(value)
          end

          it 'does not raise an error' do
            expect { handler.call(result) }.not_to raise_error
          end
        end

        context 'when the result is Failure' do
          context 'and the failure is retryable by type' do
            let(:failure) do
              {
                type: :submission_exception,
                message: 'timeout'
              }
            end

            let(:result) { Dry::Monads::Failure(failure) }

            it 'raises a RetryableSubmissionFailedError' do
              expect { handler.call(result) }.to raise_error(RetryableSubmissionFailedError) do |error|
                expect(error.failure).to eq(failure)
              end
            end
          end

          context 'and the failure is retryable by HTTP status' do
            let(:failure) do
              {
                type: :submission_http_error,
                status: 503,
                body: '<error/>'
              }
            end

            let(:result) { Dry::Monads::Failure(failure) }

            it 'raises a RetryableSubmissionFailedError' do
              expect { handler.call(result) }.to raise_error(RetryableSubmissionFailedError)
            end
          end

          context 'and the failure is NOT retryable' do
            let(:failure) do
              {
                type: :submission_http_error,
                status: 400,
                body: '<bad-request/>'
              }
            end

            let(:result) { Dry::Monads::Failure(failure) }

            it 'raises a NonRetryableSubmissionFailedError' do
              expect { handler.call(result) }.to raise_error(NonRetryableSubmissionFailedError) do |error|
                expect(error.failure).to eq(failure)
              end
            end
          end
        end
      end
    end
  end
end
