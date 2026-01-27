# frozen_string_literal: true

require 'rails_helper'

module Hmrc
  module Ct600
    RSpec.describe SubmissionApiClient do
      let(:client) { described_class.new }
      let(:ixbrl) { '<ixbrl>dummy</ixbrl>' }
      let(:utr) { '1234567890' }
      let(:oauth_token) { double('OauthToken', authorization_header: 'Bearer abc123') }
      let(:endpoint) { 'https://example.com/submissions' }

      before do
        allow(Ct600Config).to receive(:submission_url).and_return(endpoint)
      end

      describe '#call' do
        context 'when the submission succeeds' do
          before do
            http_double = instance_double(Net::HTTP)
            allow(Net::HTTP).to receive(:start).and_yield(http_double)

            success_response = Net::HTTPSuccess.new('1.1', '200', 'OK').tap do |r|
              allow(r).to receive(:body).and_return('<response>ok</response>')
            end

            allow(http_double).to receive(:request).and_return(success_response)
          end

          it 'returns Success with body and status' do
            result = client.call(ixbrl: ixbrl, utr: utr, oauth_token: oauth_token)
            expect(result).to be_a(Dry::Monads::Result::Success)
            expect(result.value!).to eq(body: '<response>ok</response>', status: 200)
          end
        end

        context 'when the submission fails HTTP' do
          before do
            http_double = instance_double(Net::HTTP)
            allow(Net::HTTP).to receive(:start).and_yield(http_double)

            bad_response = Net::HTTPBadRequest.new('1.1', '400', 'bad request').tap do |r|
              allow(r).to receive(:body).and_return('<response>bad request</response>')
            end

            allow(http_double).to receive(:request).and_return(bad_response)
          end

          it 'returns Failure with type :submission_http_error' do
            result = client.call(ixbrl: ixbrl, utr: utr, oauth_token: oauth_token)
            expect(result).to be_a(Dry::Monads::Result::Failure)
            expect(result.failure[:type]).to eq(:submission_http_error)
            expect(result.failure[:status]).to eq(400)
            expect(result.failure[:body]).to eq('<response>bad request</response>')
          end
        end

        context 'when an exception occurs during the request' do
          before do
            allow(Net::HTTP).to receive(:start).and_raise(StandardError.new('network failure'))
          end

          it 'returns Failure with type :submission_exception' do
            result = client.call(ixbrl: ixbrl, utr: utr, oauth_token: oauth_token)
            expect(result).to be_a(Dry::Monads::Result::Failure)
            expect(result.failure[:type]).to eq(:submission_exception)
            expect(result.failure[:message]).to eq('network failure')
            expect(result.failure[:exception]).to eq('StandardError')
          end
        end
      end
    end
  end
end
