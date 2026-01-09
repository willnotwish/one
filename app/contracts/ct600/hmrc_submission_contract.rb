# frozen_string_literal: true

# app/contracts/ct600/hmrc_submission_contract.rb
module Ct600
  # Contract to check submission. Strict values in floored pounds, per HMRC rules.
  # *Not* intended to check user-entered input params.
  class HmrcSubmissionContract < ApplicationContract
    PoundsSterling = StrictTypes::PositiveInteger

    schema do
      required(:non_trading_loan_profits).filled(PoundsSterling)
      required(:profits_before_other_deductions_and_reliefs).filled(PoundsSterling)
      required(:losses_on_unquoted_shares).filled(PoundsSterling)
      required(:management_expenses).filled(PoundsSterling)
    end

    rule(:losses_on_unquoted_shares, :profits_before_other_deductions_and_reliefs) do
      if values[:losses_on_unquoted_shares] > values[:profits_before_other_deductions_and_reliefs]
        key.failure(:hmrc9166)
      end
    end

    rule(:management_expenses, :profits_before_other_deductions_and_reliefs, :losses_on_unquoted_shares) do
      max = values[:profits_before_other_deductions_and_reliefs] - values[:losses_on_unquoted_shares]
      key.failure(:hmrc9167) if values[:management_expenses] > max
    end
  end
end
