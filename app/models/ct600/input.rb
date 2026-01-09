# frozen_string_literal: true

module Ct600
  # Models form inputs
  class Input
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :company_name, :string
    attribute :company_number, :string

    attribute :non_trading_loan_profits, :integer, default: 0
    attribute :profits_before_deductions, :integer, default: 0
    # attribute :losses_on_unquoted_shares, :integer, default: 0
    attribute :management_expenses, :integer, default: 0
  end
end
