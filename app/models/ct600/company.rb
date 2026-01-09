# frozen_string_literal: true

module Ct600
  # Representation of a company subject to Corporation Tax legislation
  class Company < Dry::Struct
    attribute :name, Types::String
    attribute :number, Types::String
  end
end
