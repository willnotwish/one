# frozen_string_literal: true

# Maps domain names to xml, but does not generate XML yet.
# Explicit and versioned. HMRC may change these mappings from year to year.
#
# Locks down canonical Ruby names:
# → exact HMRC XML element names
# → namespace
module Ct600
  module Ixbrl
    module FactMapping
      V2024 = {
        non_trading_loan_profits_and_gains: {
          element: 'NonTradingLoanProfitsAndGains',
          namespace: 'ct'
        },
        management_expenses: {
          element: 'ManagementExpenses',
          namespace: 'ct'
        }
      }.freeze
    end
  end
end
