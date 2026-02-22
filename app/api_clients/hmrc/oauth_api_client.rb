# frozen_string_literal: true

require 'net/http'

module Hmrc
  # Used to obtain an access token from HMRC endpoint.
  # Mondaic - suitable for direct use as an operation step.
  class OauthApiClient
    include Dry::Monads[:result]

    def call
      uri = URI.parse(token_url)

      request = Net::HTTP::Post.new(uri)
      request.basic_auth(client_id, client_secret)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.set_form_data(
        grant_type: 'client_credentials',
        scope: scope
      )

      response = perform_request(uri, request)

      parse_response(response)
    rescue StandardError => e
      Failure(
        type: :oauth_exception,
        message: e.message,
        exception: e.class.name
      )
    end

    private

    def perform_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    end

    def parse_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        return Failure(
          type: :oauth_http_error,
          status: response.code.to_i,
          body: response.body
        )
      end

      body = JSON.parse(response.body)

      access_token = body['access_token']
      token_type   = body['token_type']
      expires_in   = body['expires_in']

      unless access_token && token_type && expires_in
        return Failure(
          type: :oauth_invalid_response,
          body: body
        )
      end

      Success(
        OauthToken.new(
          access_token: access_token,
          token_type: token_type,
          expires_in: expires_in.to_i,
          obtained_at: Time.now.utc
        )
      )
    end

    delegate :token_url, :client_id, :client_secret, :scope, to: OauthConfig
  end
end
