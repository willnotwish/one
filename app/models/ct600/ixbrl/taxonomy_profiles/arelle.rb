# frozen_string_literal: true

module Ct600
  module Ixbrl
    module TaxonomyProfiles
      # Schema hrefs to be used to validate using local schemas: includes HMRC - iXBRL shim
      class Arelle < Base
        SHIM_VERSION = 'v1'
        # 2650

        def shim_schema_href
          "/taxonomies/arelle-shims/ct/shim-#{SHIM_VERSION}.xsd"
        end

        def frs102_schema_href
          "/taxonomies/FRC-#{year}-Taxonomy-v1.0.0/FRS-102/#{year}-01-01/FRS-102-#{year}-01-01.xsd"
        end

        def hmrc_schema_href
          '/taxonomies/HMRC-CT-2014-v1-994/CT-2014-v1-994.xsd'
        end

        def schema_hrefs
          [
            hmrc_schema_href,
            frs102_schema_href,
            shim_schema_href
          ]
        end
      end
    end
  end
end
