# frozen_string_literal: true

module Hmrc
  # Corporation Tax config
  class Ct600Config < ApplicationConfig
    class << self
      def utr
        utr = fetch_from_env!('HMRC_CT600_UTR')
        raise "Invalid CT UTR: #{utr.inspect}" unless utr =~ /\A\d{10}\z/

        utr
      end

      # Base URL for HMRC CT600 submission endpoint (sandbox or production)
      def submission_url
        fetch_from_env!('HMRC_CT600_SUBMISSION_URL')
      end
    end
  end
end
