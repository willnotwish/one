# frozen_string_literal: true

module Ct600
  module Ixbrl
    # app/services/ct600/ixbrl/namespaces.rb
    module Namespaces
      IXBRL = 'http://www.xbrl.org/2013/inlineXBRL'
      XBRLI = 'http://www.xbrl.org/2003/instance'
      LINK  = 'http://www.xbrl.org/2003/linkbase'
      XLINK = 'http://www.w3.org/1999/xlink'
      ISO4217 = 'http://www.xbrl.org/2003/iso4217'

      # CT taxonomy namespace (matches what's in CT-2014-v1-994.xsd). Will vary by year
      CT = 'http://www.govtalk.gov.uk/taxation/CT/5'

      # Hash suitable for xml.html(...) or xml.root(...)
      def self.html_attributes
        {
          xmlns: 'http://www.w3.org/1999/xhtml',
          'xmlns:ix' => IXBRL,
          'xmlns:xbrli' => XBRLI,
          'xmlns:link' => LINK,
          'xmlns:xlink' => XLINK,
          'xmlns:iso4217' => ISO4217,
          'xmlns:ct' => CT
        }
      end
    end

    # Versioned by year
    module FactMapping
      V2024 = {
        non_trading_loan_profits_and_gains: {
          element: 'NonTradingLoanProfitsAndGains',
          namespace: 'ct'
        },
        profits_before_other_deductions_and_reliefs: {
          element: 'ProfitsBeforeOtherDeductionsAndReliefs',
          namespace: 'ct'
        },
        losses_on_unquoted_shares: {
          element: 'LossesOnUnquotedShares',
          namespace: 'ct'
        },
        management_expenses: {
          element: 'ManagementExpenses',
          namespace: 'ct'
        }
      }.freeze

      def self.for(version)
        const_get(version)
      end
    end
  end
end
