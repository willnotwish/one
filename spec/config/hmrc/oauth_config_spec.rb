# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hmrc::OauthConfig do
  describe ".token_url" do
    it "returns the token URL from ENV" do
      ClimateControl.modify(
        HMRC_OAUTH_TOKEN_URL: "https://test.hmrc.gov.uk/oauth/token"
      ) do
        expect(described_class.token_url)
          .to eq("https://test.hmrc.gov.uk/oauth/token")
      end
    end

    it "raises if missing" do
      ClimateControl.modify(HMRC_OAUTH_TOKEN_URL: nil) do
        expect {
          described_class.token_url
        }.to raise_error(KeyError, /HMRC_OAUTH_TOKEN_URL/)
      end
    end
  end

  describe ".client_id" do
    it "returns the client_id from ENV" do
      ClimateControl.modify(HMRC_CLIENT_ID: "test-client-id") do
        expect(described_class.client_id).to eq("test-client-id")
      end
    end
  end

  describe ".client_secret" do
    it "returns the client_secret from ENV" do
      ClimateControl.modify(HMRC_CLIENT_SECRET: "test-client-secret") do
        expect(described_class.client_secret).to eq("test-client-secret")
      end
    end
  end

  describe ".scope" do
    it "returns the configured scope" do
      ClimateControl.modify(HMRC_OAUTH_SCOPE: "write:ctc") do
        expect(described_class.scope).to eq("write:ctc")
      end
    end

    it "defaults to write:ctc when missing" do
      ClimateControl.modify(HMRC_OAUTH_SCOPE: nil) do
        expect(described_class.scope).to eq("write:ctc")
      end
    end
  end
end
