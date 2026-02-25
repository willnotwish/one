# frozen_string_literal: true

# app/operations/ct600/build_return_operation.rb
module Ct600
  # ROP pipeline to build ixbrl from form params
  class BuildReturnOperation < ApplicationOperation
    # Builds using a sequence of steps - a ROP pipeline.
    # If all steps succeed, it #call returns a results hash wrapped in a Success monad.
    # If a Failure is returned by any step, subsequent steps are skipped and the operation short circuited,
    # returning a Failure to the caller. Callers can inspect or pattern match to extract detailed results.
    def call(params:, profile: :arelle)
      input_form_contract = InputContract.new
      hmrc_submission_contract = HmrcSubmissionContract.new

      normalized = step_with_logging(:normalize_params) do
        normalize_params(params)
      end

      input = step_with_logging(:validate_input) do
        validate_against_contract(input: normalized, contract: input_form_contract)
      end
      
      coerced = step_with_logging(:coerce_dates) do
        coerce_dates(input)
      end

      company = step_with_logging(:build_company) do
        build_company(**coerced)
      end

      period = step_with_logging(:build_period) do
        build_period(**coerced)
      end

      figures = step_with_logging(:calculate_figures) do
        calculate_figures(coerced)
      end

      submission = step_with_logging(:build_submission) do
        build_submission(company:, period:, figures:)
      end

      step_with_logging(:assert_submission_compliance) do
        validate_against_contract(input: submission.to_h, contract: hmrc_submission_contract)
      end

      # Legacy CT600 XML
      xml_schema_context = step_with_logging(:build_xml_schema_context) do
        build_xml_schema_context(period:)
      end

      legacy_xml = step_with_logging(:render_xml) do
        render_xml(submission:, schema_version: xml_schema_context.version)
      end

      # iXBRL
      ixbrl_rendering_context = step_with_logging(:build_rendering_context) do
        build_rendering_context(submission:, profile:)
      end

      ixbrl = step_with_logging(:render_ixbrl) do
        render_ixbrl(submission, rendering_context: ixbrl_rendering_context)
      end

      # results hash returned to the caller (wrapped in a Success).
      # TODO: consider replacing this with a domain result (value) object
      { input:, coerced:, submission:, legacy_xml:, ixbrl: }
    end

    private

    # Helpers designed to be called as operation steps.
    # All are "monadic" (return Success or Failure) in order to participate in ROP orchestration.

    # Normalize initial parameters by extracting native Date from Rails date helper format
    def normalize_params(params)
      NormalizeParamsOperation.new.call(params)
    end

    # Coerces ISO8601-formatted period start & end dates into native Date objects
    def coerce_dates(input, fields: %i[period_starts_on period_ends_on])
      dates = {}
      fields.each do |attr|
        dates[attr] = Date.iso8601(input[attr])
      end
      Success(input.merge(dates))
    end

    # Does the given input comply with the specified contract?
    def validate_against_contract(input:, contract:, **)
      result = contract.call(input)
      return Failure(result.errors.to_h) unless result.success?

      Success(result.to_h)
    end

    def build_company(company_name:, company_number:, **)
      Success(
        Company.new(name: company_name, number: company_number)
      )
    end

    def build_period(period_starts_on:, period_ends_on:, **)
      Success(
        Period.new(starts_on: period_starts_on, ends_on: period_ends_on)
      )
    end

    def calculate_figures(input)
      figures = Figures.new(
        non_trading_loan_profits_and_gains: input[:non_trading_loan_profits].floor,
        profits_before_other_deductions_and_reliefs: input[:profits_before_other_deductions_and_reliefs].floor,
        losses_on_unquoted_shares: input[:losses_on_unquoted_shares].floor,
        management_expenses: input[:management_expenses].floor
      )
      Success(figures)
    end

    # Builds an immutable Submission value object
    def build_submission(company:, period:, figures:)
      Success(
        Submission.new(company:, period:, figures:)
      )
    end

    def build_xml_schema_context(period:)
      service = LegacyXml::SchemaContextBuilder.new
      service.call(period:)
    end

    def render_xml(submission:, schema_version:, utr: Hmrc::Ct600Config.utr)
      service = LegacyXml::Generator.new
      Success(
        service.call(submission:, schema_version:, utr:)
      )
    end

    def build_rendering_context(submission:, profile:)
      year = submission.period.ends_on.year
      # Assume profile and year are supported.
      # If not, it's a coding error to have got this far.
      Success(
        Ixbrl::RenderingContextBuilder.new.call(year:, profile:)
      )
    end

    # Renders a submission as ixbrl
    def render_ixbrl(submission, rendering_context:)
      # The generator is not monadic, but has no failure modes (yet). Hence the Success wrapper
      Success(
        Ixbrl::Generator.new.call(submission, rendering_context:)
      )
    end
  end
end
