# frozen_string_literal: true

# app/contracts/ct600/input_contract.rb
module Ct600
  # Contract to validate input http params
  class InputContract < ApplicationContract
    Currency = InputTypes::PositiveDecimal

    register_macro(:max_scale) do |macro:|
      max_scale = macro.args[0]
      key.failure(:max_scale_exceeded, max_scale:) if value.scale > max_scale
    end

    params do
      required(:non_trading_loan_profits).filled(Currency)
      required(:profits_before_other_deductions_and_reliefs).filled(Currency)
      required(:losses_on_unquoted_shares).filled(Currency)
      required(:management_expenses).filled(Currency)
    end

    rule(:non_trading_loan_profits).validate(max_scale: 2)
    rule(:profits_before_other_deductions_and_reliefs).validate(max_scale: 2)
    rule(:losses_on_unquoted_shares).validate(max_scale: 2)
    rule(:management_expenses).validate(max_scale: 2)
  end
end
