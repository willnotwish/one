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

    def execute_service_step(step_name, service:, **args)
      logger.tagged(operation_tag, step_name) do
        logger.debug "Starting service step: #{step_name}, service class: #{service.class.name}"
        result = service.call(**args)
                        .tap { |r| log_result(r) }
        step(result)
      end
    end

    def execute_step(step_name)
      raise ArgumentError, 'requires block' unless block_given?

      logger.tagged(operation_tag, step_name) do
        logger.debug "Starting step: #{step_name}"
        result = yield
        log_result(result)
        step(result)
      end
    end
    alias step_with_logging execute_step

    def log_result(result)
      case result
      when Dry::Monads::Success
        logger.info "Success: #{result.success.inspect}"
      when Dry::Monads::Failure
        logger.warn "Failure: #{result.failure.inspect}"
      else
        logger.error "Steps must return Success or Failure. You returned: #{result}"
      end
    end

    def operation_tag
      self.class.name.underscore.dasherize
    end
  end
end
