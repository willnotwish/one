# frozen_string_literal: true

# app/operations/ct600/validate_input.rb
module Ct600
  # Validates form input
  class ValidateInput < ApplicationOperation
    def call(params)
      result = InputContract.new.call(params)
      return Failure(result.errors.to_h) unless result.success?

      Success(result.to_h)
    end
  end
end
