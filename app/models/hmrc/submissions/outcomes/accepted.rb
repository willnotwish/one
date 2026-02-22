# frozen_string_literal: true

module Hmrc
  module Submissions
    module Outcomes
      # Accepted by HMRC
      class Accepted < Base
        attribute :hmrc_reference, Types::String
      end
    end
  end
end
