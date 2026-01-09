# frozen_string_literal: true

module Ct600
  # Types used by Ct600 form input objects
  module InputTypes
    include Dry.Types()

    PositiveDecimal = Params::Decimal.constrained(gteq: 0)
  end
end
