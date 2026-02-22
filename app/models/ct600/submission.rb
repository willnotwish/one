# frozen_string_literal: true

module Ct600
  # Representation of a CT600 submission to HMRC
  class Submission < Dry::Struct
    attribute :company, Company
    attribute :period,  Period
    attribute :figures, Figures

    attribute :accounting_standards_applied, Types::String.default('FRS 102')
    attribute :audit_status, Types::String.default('Audited')
    attribute :accounts_type, Types::String.default('FullAccounts')
    attribute :authorized_on, Types::Date.default(Date.today.freeze)
    attribute :authorized_by, Types::String.default('John Doe')
    attribute :dormant, Types::Bool.default(false)
  end
end
