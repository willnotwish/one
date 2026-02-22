# frozen_string_literal: true

module Hmrc
  module Submissions
    # Takes a raw HMRC response (status, body) and turns it into an "outcome".
    # Returns Success(outcome) or Failure(outcome)
    class ResponseParser
      include Dry::Monads[:result]

      def call(status:, body:)
        case status
        when 200..299
          # Business as usual success unless HMRC reference is missing (unexpected malformed response)
          hmrc_reference = extract_hmrc_reference(body)
          return Failure(Outcomes::UnexpectedError.new(status:, body:)) unless hmrc_reference

          Success(Outcomes::Accepted.new(status:, body:, hmrc_reference:))
        when 429 # rate limit
          # Unexpected: a Failure in order to short circuit the operation
          Failure(Outcomes::UnexpectedError.new(status:, body:))
        when 400..499
          # Business as usual rejection: a Success because we don't want to short circuit the operation
          Success(Outcomes::Rejected.new(status:, body:))
        else
          # Unexpected: a Failure in order to short circuit the operation
          Failure(Outcomes::UnexpectedError.new(status:, body:))
        end
      end

      private

      # Keep this deliberately simple for now
      def extract_hmrc_reference(body)
        body[/<ReceiptID>([^<]+)<\/ReceiptID>/, 1]
      end
    end
  end
end
