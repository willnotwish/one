# frozen_string_literal: true

module Ct600
  # Representation of a company subject to Corporation Tax legislation
  class Company < Dry::Struct
    attribute :name, Types::String.default('Acme Trading Limited')
    attribute :number, Types::String.default('01234567')

    attribute :principal_activities, Types::String.default('Software Engineering')
    attribute :average_employee_count, Types::Integer.constrained(gt: 0).default(5)
    attribute :trading_status, Types::String.default('Active')
    attribute :legal_form, Types::String.default('PrivateLimitedCompany')
  end
end
