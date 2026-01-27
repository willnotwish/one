# frozen_string_literal: true

require 'rails_helper'

# spec/operations/ct600/submit_return_operation_spec.rb
# Tests three main contexts:
# - happy path
# - OAuth failure
# - submission failure
module Ct600
  RSpec.describe SubmitReturnOperation do
    subject(:operation) { described_class.new }

    let(:ixbrl) { '<ixbrl>valid</ixbrl>' }
    let(:utr) { '1111222233' }
    let(:oauth_token) { instance_double(Hmrc::OauthToken, authorization_header: 'Bearer test-token') }
    let(:oauth_client) { instance_double(Hmrc::OauthApiClient) }
    let(:submission_client) { instance_double(Hmrc::Ct600::SubmissionApiClient) }

    before do
      allow(Hmrc::OauthApiClient).to receive(:new).and_return(oauth_client)
      allow(Hmrc::Ct600::SubmissionApiClient).to receive(:new).and_return(submission_client)
    end

    context 'when oauth and submission succeed' do
      let(:submission_response) do
        { status: 200, body: '<ok/>' }
      end

      before do
        allow(oauth_client)
          .to receive(:call)
          .and_return(Dry::Monads::Success(oauth_token))

        allow(submission_client)
          .to receive(:call)
          .with(ixbrl: ixbrl, utr: utr, oauth_token: oauth_token)
          .and_return(Dry::Monads::Success(submission_response))
      end

      it 'returns Success' do
        result = operation.call(ixbrl: ixbrl, utr: utr)

        expect(result).to be_success
        expect(result.value!).to eq(submission_response)
      end
    end

    context 'when oauth fails' do
      let(:failure) do 
        { type: :oauth_http_error }
      end

      before do
        allow(oauth_client)
          .to receive(:call)
          .and_return(Dry::Monads::Failure(failure))
      end

      it 'returns Failure and does not submit' do
        result = operation.call(ixbrl: ixbrl, utr: utr)

        expect(result).to be_failure
        expect(result.failure).to eq(failure)

        expect(submission_client).not_to receive(:call)
      end
    end

    context 'when submission fails' do
      let(:failure) do
        { type: :submission_http_error }
      end

      before do
        allow(oauth_client)
          .to receive(:call)
          .and_return(Dry::Monads::Success(oauth_token))

        allow(submission_client)
          .to receive(:call)
          .and_return(Dry::Monads::Failure(failure))
      end

      it 'returns Failure' do
        result = operation.call(ixbrl: ixbrl, utr: utr)

        expect(result).to be_failure
        expect(result.failure).to eq(failure)
      end
    end
  end
end
