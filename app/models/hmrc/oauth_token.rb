# frozen_string_literal: true

# app/models/hmrc/oauth_token.rb
module Hmrc
  # Used below
  module Types
    include Dry.Types()
  end

  # Models an HMRC oauth token: immutable, typed.
  class OauthToken < Dry::Struct
    attribute :access_token, Types::String
    attribute :token_type,   Types::String
    attribute :expires_in,   Types::Integer
    attribute :obtained_at,  Types::Time

    def authorization_header
      "#{token_type.capitalize} #{access_token}"
    end
  end
end
