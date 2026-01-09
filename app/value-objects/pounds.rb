# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'

# Value object
class Pounds
  include Comparable

  attr_reader :value

  # Accept numeric, string, or BigDecimal
  def initialize(amount)
    @value = BigDecimal(amount.to_s)
    raise ArgumentError, 'Amount cannot be negative' if @value.negative?
  end

  # Floors to whole pounds
  def floor_whole_pounds
    @value.floor
  end

  # For iXBRL: floor to whole pounds, format with two decimals
  def to_ixbrl
    format('%.2f', floor_whole_pounds)
  end

  # Arithmetic operations
  def +(other)
    Pounds.new(value + other.to_bd)
  end

  def -(other)
    result = value - other.to_bd
    raise ArgumentError, 'Result cannot be negative' if result.negative?

    Pounds.new(result)
  end

  def *(other)
    Pounds.new(value * BigDecimal(other.to_s))
  end

  def /(other)
    Pounds.new(value / BigDecimal(other.to_s))
  end

  # Comparable support
  def <=>(other)
    value <=> other.to_bd
  end

  # Coerce to BigDecimal
  def to_bd
    value
  end

  def to_s
    value.to_s('F')
  end
end
