# frozen_string_literal: true

require 'rails_helper'

module Hmrc
  RSpec.describe OauthApiClient do
    let(:client) { described_class.new }

    let(:token_response_body) do
      {
        access_token: 'abcd1234',
        token_type: 'Bearer',
        expires_in: 3600
      }.to_json
    end

    let(:uri) { URI.parse(Hmrc::OauthConfig.token_url) }

    before do
      # Stub all config values via the wrapper
      allow(Hmrc::OauthConfig).to receive(:token_url).and_return('https://example.com/oauth/token')
      allow(Hmrc::OauthConfig).to receive(:client_id).and_return('client-id')
      allow(Hmrc::OauthConfig).to receive(:client_secret).and_return('client-secret')
      allow(Hmrc::OauthConfig).to receive(:scope).and_return('write:ctc')
    end

    describe '#call' do
      context 'when the request succeeds' do
        before do
          http_double = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:start).with(
            uri.host, uri.port, use_ssl: uri.scheme == 'https'
          ).and_yield(http_double)

          response_double = instance_double(Net::HTTPSuccess, body: token_response_body, is_a?: true)
          allow(http_double).to receive(:request).and_return(response_double)
        end

        it 'returns a Success with an OauthToken' do
          result = client.call
          expect(result).to be_a(Dry::Monads::Result::Success)

          token = result.value!
          expect(token).to have_attributes(
            access_token: 'abcd1234',
            token_type: 'Bearer',
            expires_in: 3600
          )
          expect(token.obtained_at).to be_within(1).of(Time.now.utc)
        end
      end

      context 'when the request fails HTTP' do
        before do
          http_double = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:start).and_yield(http_double)
          response_double = instance_double(Net::HTTPResponse, code: '400', body: 'bad request')
          allow(http_double).to receive(:request).and_return(response_double)
        end

        it 'returns a Failure with type :oauth_http_error' do
          result = client.call
          expect(result).to be_a(Dry::Monads::Result::Failure)
          expect(result.failure[:type]).to eq(:oauth_http_error)
          expect(result.failure[:status]).to eq(400)
          expect(result.failure[:body]).to eq('bad request')
        end
      end

      context 'when the response is missing required fields' do
        before do
          http_double = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:start).and_yield(http_double)
          response_double = instance_double(Net::HTTPSuccess, body: { foo: 'bar' }.to_json, is_a?: true)
          allow(http_double).to receive(:request).and_return(response_double)
        end

        it 'returns a Failure with type :oauth_invalid_response' do
          result = client.call
          expect(result).to be_a(Dry::Monads::Result::Failure)
          expect(result.failure[:type]).to eq(:oauth_invalid_response)
          expect(result.failure[:body]).to eq({ 'foo' => 'bar' })
        end
      end

      context 'when an exception is raised during request' do
        before do
          allow(Net::HTTP).to receive(:start).and_raise(StandardError.new('network failure'))
        end

        it 'returns a Failure with type :oauth_exception' do
          result = client.call
          expect(result).to be_a(Dry::Monads::Result::Failure)
          expect(result.failure[:type]).to eq(:oauth_exception)
          expect(result.failure[:message]).to eq('network failure')
          expect(result.failure[:exception]).to eq('StandardError')
        end
      end
    end
  end
end
