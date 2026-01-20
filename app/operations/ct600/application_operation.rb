# frozen_string_literal: true

# app/operations/ct600/application_operation.rb
module Ct600
  # Base class for all operations
  class ApplicationOperation < Dry::Operation
    include Dry::Monads[:result, :do]

    # Safe lazy evaluation to avoid problematic circular dependencies
    def logger
      Rails.logger
    end

    private

    def step_with_logging(step_name)
      logger.tagged(operation_tag, step_name) do
        logger.debug('Starting...')
        step(yield).tap { |result| log_step_result(result) }
      end
    end

    def log_step_result(result)
      case result
      when Dry::Monads::Success
        logger.info 'Success'
      when Dry::Monads::Failure
        logger.warn "Failure: #{result.failure.inspect}"
      end
    end

    def operation_tag
      self.class.name.underscore.dasherize
    end
  end
end
