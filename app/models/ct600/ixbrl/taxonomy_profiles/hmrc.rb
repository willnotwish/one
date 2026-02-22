# frozen_string_literal: true

module Ct600
  module Ixbrl
    module TaxonomyProfiles
      # Schema hrefs to be used to when submitting to HMRC; no shim needed
      class Hmrc < Base
        def frs102_href
          "https://xbrl.frc.org.uk/FRS-102/#{year}-01-01/FRS-102-#{year}-01-01.xsd"
        end

        def hmrc_href
          'https://www.hmrc.gov.uk/schemas/ct/CT-2014-v1-994.xsd'
        end

        def schema_hrefs
          [
            frs102_href,
            hmrc_href
          ]
        end
      end
    end
  end
end
