# frozen_string_literal: true

# app/services/ct600/submit_return.rb
module Ct600
  # Submit return service
  class SubmitReturn
    Result = Struct.new(
      :input,
      :calculated,
      :submission,
      keyword_init: true
    )

    # Raised if invalid input detected
    class InputInvalid < StandardError
      attr_reader :result

      def initialize(result)
        @result = result
        super('Invalid input')
      end
    end

    class SubmissionInvalid < StandardError; end

    def call(params)
      # 1. Input validation / coercion
      input_result = InputContract.new.call(params)
      raise InputInvalid, input_result unless input_result.success?

      # 2. Calculations (floors happen here)
      calculated = Calculation.new.call(input_result.to_h)

      # 3. HMRC validation
      submission_result = HmrcSubmissionContract.new.call(calculated)
      raise SubmissionInvalid, submission_result.errors.to_h unless submission_result.success?

      Result.new(
        input: input_result.to_h,
        calculated: calculated,
        submission: submission_result.to_h
      )
    end
  end
end
