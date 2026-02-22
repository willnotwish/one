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

    # XBRL concepts versioned by year
    module FactMapping
      RAW_V2024 = {
        start_date_for_period_covered_by_report: {
          name: 'StartDateForPeriodCoveredByReport',
          namespace: 'ct',
          type: :non_numeric,
          context_ref: :period_duration,
          source: :period,
          source_attribute: :starts_on
        },
        end_date_for_period_covered_by_report: {
          name: 'EndDateForPeriodCoveredByReport',
          namespace: 'ct',
          type: :non_numeric,
          context_ref: :period_duration,
          source: :period,
          source_attribute: :ends_on
        },
        accounting_standards_applied: {
          name: 'AccountingStandardsApplied',
          namespace: 'ct',
          type: :non_numeric,
          context_ref: :period_duration,
          source: :submission,
          source_attribute: :accounting_standards_applied
        },
        description_principal_activities: {
          name: 'DescriptionPrincipalActivities',
          namespace: 'ct',
          type: :non_numeric,
          context_ref: :period_duration,
          source: :company,
          source_attribute: :principal_activities
        },
        average_number_employees_during_period: {
          name: 'AverageNumberEmployeesDuringPeriod',
          namespace: 'ct',
          type: :non_fraction,
          context_ref: :period_duration,
          unit_ref: :pure,
          decimals: 0,
          source: :company,
          source_attribute: :average_employee_count
        },
        non_trading_loan_profits_and_gains: {
          name: 'NonTradingLoanProfitsAndGains',
          namespace: 'ct',
          type: :non_fraction,
          context_ref: :period_duration,
          unit_ref: :gbp,
          decimals: 0,
          source: :figures,
          source_attribute: :non_trading_loan_profits_and_gains
        },
        profits_before_other_deductions_and_reliefs: {
          name: 'ProfitsBeforeOtherDeductionsAndReliefs',
          namespace: 'ct',
          type: :non_fraction,
          context_ref: :period_duration,
          unit_ref: :gbp,
          decimals: 0,
          source: :figures,
          source_attribute: :profits_before_other_deductions_and_reliefs
        },
        losses_on_unquoted_shares: {
          name: 'LossesOnUnquotedShares',
          namespace: 'ct',
          type: :non_fraction,
          context_ref: :period_duration,
          unit_ref: :gbp,
          decimals: 0,
          source: :figures,
          source_attribute: :losses_on_unquoted_shares
        },
        management_expenses: {
          name: 'ManagementExpenses',
          namespace: 'ct',
          type: :non_fraction,
          context_ref: :period_duration,
          unit_ref: :gbp,
          decimals: 0,
          source: :figures,
          source_attribute: :management_expenses
        },
        accounts_status_audited_or_unaudited: {
          name: 'AccountsStatusAuditedOrUnaudited',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :submission,
          source_attribute: :audit_status
        },
        accounts_type: {
          name: 'AccountsType',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :submission,
          source_attribute: :accounts_type
        },
        balance_sheet_date: {
          name: 'BalanceSheetDate',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :period,
          source_attribute: :ends_on
        },
        date_authorisation_financial_statements_for_issue: {
          name: 'DateAuthorisationFinancialStatementsForIssue',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :submission,
          source_attribute: :authorized_on
        },
        director_signing_financial_statements: {
          name: 'DirectorSigningFinancialStatements',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :submission,
          source_attribute: :authorized_by
        },
        entity_current_legal_or_registered_name: {
          name: 'EntityCurrentLegalOrRegisteredName',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :company,
          source_attribute: :name
        },
        entity_trading_status: {
          name: 'EntityTradingStatus',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :company,
          source_attribute: :trading_status
        },
        legal_form_entity: {
          name: 'LegalFormEntity',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :company,
          source_attribute: :legal_form
        },
        entity_dormant_true_or_false: {
          name: 'EntityDormantTruefalse',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :submission,
          source_attribute: :dormant
        },
        uk_companies_house_registered_number: {
          name: 'UKCompaniesHouseRegisteredNumber',
          namespace: 'ct',
          context_ref: :period_end,
          type: :non_numeric,
          source: :company,
          source_attribute: :number
        }
      }.freeze

      def self.for_year(_year)
        @v2024 ||= RAW_V2024.each_with_object({}) do |(key, attrs), acc|
          contract = ::Ixbrl::FactSpecificationContract.new
          validated = contract.call(attrs)
          if validated.failure?
            raise "Invalid fact mapping for key #{key} (#{attrs[:name] || attrs}): #{validated.errors.to_h}"
          end

          acc[key] = FactSpecification.new(validated.to_h)
        end.freeze
      end

      def self.reset_cache!
        @v2024 = nil
      end
    end

    Rails.application.reloader.to_prepare do
      FactMapping.reset_cache! if Rails.env.development?
    end

    module Contexts
      REGISTRY = {
        period_duration: {
          id: 'ctxPeriodDuration',
          type: :duration
        },
        period_end: {
          id: 'ctxPeriodEnd',
          type: :instant
        }
      }.freeze

      def self.context_for(name)
        REGISTRY.fetch(name) do
          raise ArgumentError, "Unknown context: #{name}"
        end
      end
    end

    module Units
      REGISTRY = {
        gbp:  'iso4217:GBP',
        pure: 'xbrli:pure'
      }.freeze

      def self.measure_for(unit_ref)
        REGISTRY.fetch(unit_ref) do
          raise ArgumentError, "Unknown unit_ref: #{unit_ref}"
        end
      end
    end
  end
end
