# frozen_string_literal: true

module Ct600
  module Ixbrl
    module Nodes
      class Context
        COMPANIES_HOUSE_SCHEME = 'http://www.companieshouse.gov.uk/'

        def call(xml:, company:, period:, id: 'ctx')
          xml['xbrli'].context_(id:) do
            xml['xbrli'].entity do
              xml['xbrli'].identifier(company.number, scheme: COMPANIES_HOUSE_SCHEME)
            end
            xml['xbrli'].period do
              xml['xbrli'].startDate(period.starts_on)
              xml['xbrli'].endDate(period.ends_on)
            end
          end
        end
      end
    end
  end
end
