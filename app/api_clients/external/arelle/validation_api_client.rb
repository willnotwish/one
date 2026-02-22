# frozen_string_literal: true

require 'net/http'

module External
  module Arelle
    # app/api_clients/external/arelle/validation_api_client.rb
    class ValidationApiClient
      include Dry::Monads[:result]

      def call(ixbrl:)
        uri = URI.parse(endpoint)

        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/xhtml+xml'
        request.body = ixbrl

        response = perform_request(uri, request)

        Success(
          status: response.code.to_i,
          body: response.body
        )
      end

      private

      def endpoint
        ENV.fetch('ARELLE_VALIDATION_URL')
      end

      def perform_request(uri, request)
        Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == 'https',
          open_timeout: 5,
          read_timeout: 60
        ) do |http|
          http.request(request)
        end
      end
    end
  end
end
