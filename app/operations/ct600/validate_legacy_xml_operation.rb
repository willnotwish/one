# frozen_string_literal: true

module Ct600
  # ROP pipeline to validate CT600 return legacy XML
  class ValidateLegacyXmlOperation < ApplicationOperation
    # Import = Dry::AutoInject(Arelle::ServiceContainer)

    # include Import[
    #   'xml_parser',
    #   'validations.arelle_client',
    #   'validations.arelle_response_parser'
    # ]

    # Validates using a sequence of steps - a ROP pipeline.
    # If all steps succeed, #call returns a validation result wrapped in a Success monad.
    # If a Failure is returned by any step, subsequent steps are skipped and the operation short circuited,
    # returning a Failure to the caller. Callers can inspect or pattern match to extract detailed results.
    def call(xml:, schema_version:)
      context = execute_service_step(
        :resolve_schema_context,
        service: schema_context_builder,
        schema_version:
      )
      
      execute_service_step(
        :validate_against_xsd,
        service: legacy_xml_validator,
        xml:,
        context:
      )
    end

    private

    # These can be replaced by dry-auto_inject if required. Services *must* be monadic.
    def schema_context_builder
      LegacyXml::SchemaContextBuilder.new
    end

    def legacy_xml_validator
      LegacyXml::Validator.new
    end
  end
end
