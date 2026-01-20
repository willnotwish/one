# frozen_string_literal: true

# app/controllers/ct600/returns_controller.rb
module Ct600
  # Old version of controller
  class OldReturnsController < ApplicationController
    def new
      # Pre-populate with zeros so form helpers work nicely
      @form = {
        non_trading_loan_profits: nil,
        profits_before_other_deductions_and_reliefs: nil,
        losses_on_unquoted_shares: nil,
        management_expenses: nil
      }
    end

    def create
      result = SubmitReturn.new.call(ct600_params) # service object does the work
      render :show, locals: { result: result } # for now, just show the calculated values
    rescue SubmitReturn::InputInvalid => e
      @form = ct600_params # re-populate the form
      @errors = e.result.errors.to_h # better than e.message, because it contains the full validation result
      render :new, status: :unprocessable_entity
    rescue SubmitReturn::SubmissionInvalid => e
      @form = ct600_params
      @errors = e.result.errors.to_h
      render :new, status: :unprocessable_entity
    end

    private

    def ct600_params
      params.require(:ct600).permit(
        :non_trading_loan_profits,
        :profits_before_other_deductions_and_reliefs,
        :losses_on_unquoted_shares,
        :management_expenses
      ).to_h
    end
  end
end
