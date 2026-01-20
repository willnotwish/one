# frozen_string_literal: true

# app/contracts/ct600/input_contract.rb
module Ct600
  # Contract to validate input http params, typically entered by the user.
  # 
  # Accepts only ISO-style dates as strings in the form 'YYYY-MM-DD'.
  # 
  # Monetary amounts are accepted as strings or numbers greater than or equal to zero;
  # zero, one or two decimal places (pence) are acceptable.
  # 
  class InputContract < ApplicationContract
    ISO_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/
    Currency = InputTypes::PositiveDecimal

    register_macro(:max_scale) do |macro:|
      max_scale = macro.args[0]
      key.failure(:max_scale_exceeded, max_scale:) if value.scale > max_scale
    end

    register_macro(:iso_date) do
      begin
        Date.iso8601(value)
      rescue ArgumentError
        key.failure(:invalid_date)
      end
    end

    params do
      required(:company_name).filled(:string)
      required(:company_number).filled(:string)

      required(:period_starts_on).filled(:string, format?: ISO_DATE_REGEX)
      required(:period_ends_on).filled(:string, format?: ISO_DATE_REGEX)
 
      required(:non_trading_loan_profits).filled(Currency)
      required(:profits_before_other_deductions_and_reliefs).filled(Currency)
      required(:losses_on_unquoted_shares).filled(Currency)
      required(:management_expenses).filled(Currency)
    end

    rule(:period_starts_on).validate(:iso_date)
    rule(:period_ends_on).validate(:iso_date)

    rule(:period_ends_on, :period_starts_on) do
      # Only run this rule if dates are good: skip if there were errors previously
      next if rule_error?(:period_ends_on) || rule_error?(:period_starts_on)

      start_date = Date.iso8601(values[:period_starts_on])
      end_date   = Date.iso8601(values[:period_ends_on])

      key(:period_ends_on).failure(:before_start) if end_date <= start_date
    end

    rule(:non_trading_loan_profits).validate(max_scale: 2)
    rule(:profits_before_other_deductions_and_reliefs).validate(max_scale: 2)
    rule(:losses_on_unquoted_shares).validate(max_scale: 2)
    rule(:management_expenses).validate(max_scale: 2)
  end
end
