# frozen_string_literal: true

# app/operations/ct600/validate_hmrc_submission.rb
module Ct600
  # Ensures calculated amounts obey HMRC rules (hmrc9166, hmrc9167, etc.)
  # Input: calculated Hash.
  # Output: floored Hash confirmed valid.
  class ValidateHmrcSubmission < ApplicationOperation
    def call(calculated)
      result = HmrcSubmissionContract.new.call(calculated)
      return Failure(result.errors.to_h) unless result.success?

      Success(result.to_h)
    end
  end
end
