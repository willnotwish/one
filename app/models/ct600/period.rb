# frozen_string_literal: true

module Ct600
  # Representation of an accounting period for the purposes of Corporation Tax
  class Period < Dry::Struct
    attribute :starts_on, Types::Date
    attribute :ends_on, Types::Date
  end
end
