# frozen_string_literal: true

module Hmrc
  module Ct600
    # HMRC submission client: used to submite CT600 returns
    class SubmissionApiClient
      include Dry::Monads[:result]

      delegate :submission_url, to: Ct600Config

      # Any HTTP response (2xx, 4xx, 5xx) is regarded as a *successful interaction*
      # If a network/server down/DNS error occurs, Net::HTTP will raise an error
      # which will bubble up and be handled at the top level (eg, in the job).
      def call(ixbrl:, utr:, oauth_token:)
        uri = URI.parse(endpoint_for(utr))

        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = oauth_token.authorization_header
        request['Content-Type'] = 'application/xml'
        request.body = ixbrl

        response = perform_request(uri, request) # raises appropriate error if network failure

        Success(
          status: response.code.to_i,
          body: response.body
        )
      end

      private

      def endpoint_for(utr)
        "#{submission_url}/#{utr}/returns"
      end

      def perform_request(uri, request)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
      end
    end
  end
end
