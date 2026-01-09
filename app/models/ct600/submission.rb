# frozen_string_literal: true

module Ct600
  # Representation of a CT600 submission to HMRC
  class Submission < Dry::Struct
    attribute :company, Company
    attribute :period,  Period
    attribute :figures, Figures
  end
end
