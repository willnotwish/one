# frozen_string_literal: true

# app/operations/ct600/perform_calculations.rb
module Ct600
  # Floors amounts according to HMRC rules.
  # Input: validated Hash.
  # Successful output: hash of floored values
  class PerformCalculations < ApplicationOperation
    def call(input)
      Success(input.transform_values(&:floor))
    rescue StandardError => e
      Failure(e)
    end
  end
end
