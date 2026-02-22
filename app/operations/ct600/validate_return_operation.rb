# frozen_string_literal: true

# app/operations/ct600/submit_return_operation.rb
module Ct600
  # ROP pipeline to validsate iXBRL using an external Arelle service
  class ValidateReturnOperation < ApplicationOperation
    Import = Dry::AutoInject(Arelle::ServiceContainer)

    include Import[
      'xml_parser',
      'validations.arelle_client',
      'validations.arelle_response_parser'
    ]

    # Submits using a sequence of steps - a ROP pipeline.
    # If all steps succeed, #call returns a result hash wrapped in a Success monad.
    # If a Failure is returned by any step, subsequent steps are skipped and the operation short circuited,
    # returning a Failure to the caller. Callers can inspect or pattern match to extract detailed results.
    def call(ixbrl:)
      execute_service_step(
        :xml_sanity_check,
        service: xml_parser,
        ixbrl:
      )
      
      response = execute_service_step(
        :call_arelle,
        service: arelle_client,
        ixbrl:
      )

      execute_service_step(
        :parse_response,
        service: arelle_response_parser,
        response:
      )
    end
  end
end
