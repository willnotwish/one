# frozen_string_literal: true

# app/operations/ct600/submit_return.rb
module Ct600
  # ROP pipeline to normalize dates submitted in "multiparam format"
  class NormalizeParamsOperation < ApplicationOperation
    def call(params, date_keys: %i[period_starts_on period_ends_on])
      normalized = params.to_h.symbolize_keys

      date_keys.each do |key|
        normalized = step(normalize_date(normalized, key))
      end

      normalized
    end

    private

    def normalize_date(params, key)
      return Success(params) unless multiparam_date?(params, key)

      build_iso_date(params, key)
    end

    def multiparam_date?(params, key)
      %i[1i 2i 3i].all? { |i| params.key?("#{key}(#{i})".to_sym) }
    end

    def build_iso_date(params, key)
      year  = params.delete("#{key}(1i)".to_sym)
      month = params.delete("#{key}(2i)".to_sym)
      day   = params.delete("#{key}(3i)".to_sym)

      date = Date.new(year.to_i, month.to_i, day.to_i)

      Success(params.merge(key => date.iso8601))
    rescue ArgumentError
      Failure(key => ['is not a valid date'])
    end
  end
end
