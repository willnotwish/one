# frozen_string_literal: true

module Hmrc
  # Takes a raw HMRC response (status, body).
  # Returns Success(parsed_response) or Failure(domain_failure_hash)
  class SubmissionResponseParser
    include Dry::Monads[:result]

    def call(raw_hmrc_response)
      status = raw_hmrc_response[:status]
      body = raw_hmrc_response[:body]
      return Failure(type: :hmrc_rejected_submission, status:, body:) unless status.between?(200, 299)

      hmrc_reference = extract_hmrc_reference(body)
      return Failure(type: :hmrc_invalid_success_response, status:, body:) unless hmrc_reference

      Success(status:, hmrc_reference:, body:)
    end

    private

    # Keep this deliberately simple for now
    def extract_hmrc_reference(body)
      body[/<ReceiptID>([^<]+)<\/ReceiptID>/, 1]
    end
  end
end
