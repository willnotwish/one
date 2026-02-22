# frozen_string_literal: true

module Hmrc
  module Submissions
    module Outcomes
      # Base for concrete result classes
      class Base < Dry::Struct
        attribute :status, Types::Integer
        attribute :body,   Types::String
      end
    end
  end
end
