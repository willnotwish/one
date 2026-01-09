# frozen_string_literal: true

module Ct600
  # Models CT600 figures (numeric amounts) prior to submission to HMRC.
  # Each attribute becomes a numeric iXBRL fact in the final xhtml document submission.
  class Figures < Dry::Struct
    attribute :non_trading_loan_profits_and_gains, Types::Integer.default(0)
    attribute :profits_before_other_deductions_and_reliefs, Types::Integer.default(0)
    attribute :losses_on_unquoted_shares, Types::Integer.default(0)
    attribute :management_expenses, Types::Integer.default(0)
  end
end
