# frozen_string_literal: true

module Ct600
  module Ixbrl
    module Nodes
      class Context
        COMPANIES_HOUSE_SCHEME = 'http://www.companieshouse.gov.uk/'

        def call(xml:, company:, period:, id: 'ctx', type: :duration)
          xml['xbrli'].context_(id:) do
            xml['xbrli'].entity do
              xml['xbrli'].identifier(company.number, scheme: COMPANIES_HOUSE_SCHEME)
            end
            xml['xbrli'].period do
              case type
              when :duration
                xml['xbrli'].startDate(period.starts_on)
                xml['xbrli'].endDate(period.ends_on)
              when :instant
                xml['xbrli'].instant(period.ends_on)
              else
                raise ArgumentError, "Invalid context type: #{type.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
