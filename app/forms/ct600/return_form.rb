# frozen_string_literal: true

# app/forms/ct600/return_form.rb
module Ct600
  # CT600 form
  class ReturnForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :company_name, :string
    attribute :company_number, :string

    attribute :period_starts_on, :string
    attribute :period_ends_on, :string

    attribute :non_trading_loan_profits, :decimal
    attribute :profits_before_other_deductions_and_reliefs, :decimal
    attribute :losses_on_unquoted_shares, :decimal
    attribute :management_expenses, :decimal

    attribute :profile, :string, default: 'arelle'

    def initialize(attributes = {}, operation: BuildReturnOperation.new)
      super(attributes)

      @operation = operation
    end

    # Public API
    attr_reader :ixbrl, :legacy_xml, :submission

    # Returns true on success (valid XHTML produced), false otherwise
    def submit
      ct600_params = attributes.except('profile').symbolize_keys
      @operation.call(params: ct600_params, profile: profile.to_sym)
                .either(
                  ->(success) { handle_success(success) },
                  ->(failure) { assign_errors_from(failure) }
                )
    end

    private

    # ActiveModel::Errors is included via ActiveModel::Model. Populate from the contract monad
    def assign_errors_from(source)
      source.each do |field, messages|
        Array(messages).each { |msg| errors.add(field, msg) }
      end
      false
    end

    def handle_success(success)
      @submission = success[:submission]
      @ixbrl = success[:ixbrl]
      @legacy_xml = success[:legacy_xml]

      true
    end
  end
end
