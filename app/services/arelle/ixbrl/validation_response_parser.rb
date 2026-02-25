# frozen_string_literal: true

module Arelle
  module Ixbrl
    # Validates the given Arelle response
    class ValidationResponseParser
      include Dry::Monads[:result]

      def call(response:)
        return Failure(type: :http_error, status: response[:status]) unless response[:status] == 200

        body = JSON.parse(response[:body])

        errors   = Array(body['errors'])
        warnings = Array(body['warnings'])

        result = Ct600::Validation::Result.new(
          valid: errors.empty?,
          errors: errors,
          warnings: warnings,
          duration_ms: body.dig('meta', 'duration_ms')
        )

        Success(result)
      rescue JSON::ParserError => e
        Failure(type: :invalid_json, message: e.message)
      end
    end
  end
end
