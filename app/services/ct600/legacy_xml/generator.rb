# frozen_string_literal: true

module Ct600
  module LegacyXml
    class Generator
      # Pure service to generate CT600 XML from a Submission.
      # Returns the XML directly as a String (no monadic wrapping)
      def call(submission:, schema_version:, utr:)
        build_ct600_xml(submission:, schema_version:, utr:)
      end

      private

      def build_ct600_xml(submission:, schema_version:, utr:)
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.CompanyTaxReturn(
            xmlns: "http://www.hmrc.gov.uk/schemas/ct/ct600/#{schema_version}"
          ) do
            xml.CompanyInformation do
              xml.CompanyName submission.company.name
              xml.UTR utr
              xml.CompanyNumber submission.company.number
            end

            xml.ReturnInformation do
              xml.AccountingPeriodStartDate submission.period.starts_on
              xml.AccountingPeriodEndDate submission.period.ends_on
            end

            xml.TaxCalculation do
              figures = submission.figures
              xml.ProfitBeforeTax figures.profits_before_other_deductions_and_reliefs
              xml.NonTradingLoanProfits figures.non_trading_loan_profits_and_gains
              xml.LossesOnUnquotedShares figures.losses_on_unquoted_shares
              xml.ManagementExpenses figures.management_expenses
            end
          end
        end.to_xml
      end
    end
  end
end
