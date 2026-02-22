# frozen_string_literal: true

module Ct600
  class ValidationsController < ApplicationController
    def new
      @ixbrl = params[:ixbrl]
    end

    def create
      @ixbrl = params[:ixbrl]

      operation = ValidateReturnOperation.new
      result = operation.call(ixbrl: @ixbrl)
      if result.success?
        @validation = result.value!
      else
        @error = result.failure
      end

      render :show
    end
  end
end
