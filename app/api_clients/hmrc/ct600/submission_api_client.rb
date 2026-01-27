# frozen_string_literal: true

module Hmrc
  module Ct600
    class SubmissionApiClient
      include Dry::Monads[:result]

      delegate :submission_url, to: Ct600Config

      def call(ixbrl:, utr:, oauth_token:)
        uri = URI.parse(endpoint_for(utr))

        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = oauth_token.authorization_header
        request["Content-Type"] = "application/xml"
        request.body = ixbrl

        response = perform_request(uri, request)

        parse_response(response)
      rescue StandardError => e
        Failure(
          type: :submission_exception,
          message: e.message,
          exception: e.class.name
        )
      end

      private

      def endpoint_for(utr)
        # Example: HMRC expects the UTR in the URL
        "#{submission_url}/organisations/corporation-tax/#{utr}/returns"
      end

      def perform_request(uri, request)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.request(request)
        end
      end

      def parse_response(response)
        case response
        when Net::HTTPSuccess
          Success(
            body: response.body,
            status: response.code.to_i
          )
        else
          Failure(
            type: :submission_http_error,
            status: response.code.to_i,
            body: response.body
          )
        end
      end
    end
  end
end
