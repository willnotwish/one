# frozen_string_literal: true

module Hmrc
  # Wraps OAuth-related configuration for HMRC APIs.
  # Source of truth is ENV (container-injected).
  class OauthConfig < ApplicationConfig
    class << self
      def token_url
        fetch_from_env!('HMRC_OAUTH_TOKEN_URL')
      end

      def client_id
        fetch_from_env!('HMRC_CLIENT_ID')
      end

      def client_secret
        fetch_from_env!('HMRC_CLIENT_SECRET')
      end

      def scope
        optional_from_env('HMRC_OAUTH_SCOPE', 'write:ctc')
      end
    end
  end
end
