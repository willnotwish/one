# frozen_string_literal: true

module Ct600
  module LegacyXml
    # Pure monadic service to validate legacy CT600 XML in the context provided
    class Validator
      include Dry::Monads[:result]

      def call(xml:, context:)
        document = Nokogiri::XML(xml, &:strict) # strict parsing: fail fast on malformed XML

        errors = context.xsd.validate(document)

        result = if errors.empty?
                   Validation::Result.new(valid: true)
                 else
                   Validation::Result.new(valid: false, errors: errors.map(&:message))
                 end
        if result.valid?
          Success(result)
        else
          Failure(result)
        end
      end
    end
  end
end
