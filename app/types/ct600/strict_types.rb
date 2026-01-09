# frozen_string_literal: true

module Ct600
  # Strict types used (for example) by HMRC calculations for CT600 submission
  module StrictTypes
    include Dry.Types()

    PositiveInteger = Strict::Integer.constrained(gteq: 0)
  end
end
