# frozen_string_literal: true

# Validates given hash against specified contract.
# Returns a validated hash (wrapped in Success) or a hash of errors wrapped in Failure.
class ValidateHashAgainstContract
  include Dry::Monads[:result]

  def call(hash, contract:)
    result = contract.call(hash)
    return Failure(result.errors.to_h) unless result.success?

    Success(result.to_h)
  end
end
