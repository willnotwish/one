# frozen_string_literal: true

module Ct600
  class ValidationsController < ApplicationController
    def new
      @ixbrl = params[:ixbrl]
    end

    def create
      @type = params[:validation_type]

      result =
        case @type
        when 'accounts_ixbrl'
          @ixbrl = params[:ixbrl]
          ValidateAccountsIxbrlOperation.new.call(ixbrl: @ixbrl)

        when 'legacy_xml'
          @xml = params[:legacy_xml]
          @schema_version = params[:schema_version]
          ValidateLegacyXmlOperation.new.call(xml: @xml, schema_version: @schema_version)
        else
          raise ArgumentError, "Unknown validation type: #{@type}"
        end

      @validation = if result.success?
                      result.value!
                    else
                      result.failure
                    end

      render :show
    end

    private

    def extract_period
    end
  end
end
