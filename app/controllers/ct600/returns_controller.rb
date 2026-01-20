# frozen_string_literal: true

# app/controllers/ct600/returns_controller.rb
module Ct600
  # Corporation tax returns controller
  class ReturnsController < ApplicationController
    before_action :prepare_form

    def new; end

    def create
      if @form.submit
        render plain: @form.ixbrl, content_type: 'text/plain'
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    FIELD_DEFAULTS = {
      company_name: 'Foobar Limited',
      company_number: '01234567',
      period_starts_on: '2024-04-01',
      period_ends_on: '2025-03-31',
      non_trading_loan_profits: 0,
      profits_before_other_deductions_and_reliefs: 0,
      losses_on_unquoted_shares: 0,
      management_expenses: 0
    }.freeze

    def ct600_return_params
      params.fetch(:ct600_return_form, FIELD_DEFAULTS)
            .permit(FIELD_DEFAULTS.keys)
            .to_h
    end

    def prepare_form
      @form = ReturnForm.new(ct600_return_params)
    end
  end
end
