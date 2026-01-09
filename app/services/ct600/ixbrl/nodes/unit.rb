# frozen_string_literal: true

module Ct600
  module Ixbrl
    module Nodes
      # Service to build xbrli:unit nodes
      class Unit
        def call(xml:, id:, measure:)
          xml['xbrli'].unit(id:) do
            xml['xbrli'].measure(measure)
          end
        end
      end
    end
  end
end
