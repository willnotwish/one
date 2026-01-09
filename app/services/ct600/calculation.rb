# frozen_string_literal: true

# app/services/ct600/calculation.rb
module Ct600
  # Applies HMRC rules. A bit of a placeholder for now
  class Calculation
    def call(input)
      input.transform_values(&:floor)
    end
  end
end
