# frozen_string_literal: true

# app/operations/ct600/generate_ixbrl.rb
module Ct600
  # Generates ixbrl xml from validated submissiom
  class GenerateIxbrl < ApplicationOperation
    # ROP compatible: returns Monads
    def call(validated_submission)
      ixbrl = Ixbrl::Generator.new.call(validated_submission)
      Success(ixbrl)
    rescue StandardError => e
      Failure(e)
    end
  end
end
