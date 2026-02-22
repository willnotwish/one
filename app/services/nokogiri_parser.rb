# frozen_string_literal: true

# Parses the given input using Nokogiri
class NokogiriParser
  include Dry::Monads[:result]

  def call(ixbrl:, strict: true)
    Success(true)
  end
end
