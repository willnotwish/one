# frozen_string_literal: true

FactoryBot.define do
  factory :ct600_ixbrl_fact, class: 'Ct600::Ixbrl::Fact' do
    name { 'ManagementExpenses' }
    namespace { 'ct' }
    value { 20 }
    context_ref { 'ctx' }
    unit_ref { 'GBP' }
    decimals { '0' }

    initialize_with do
      Ct600::Ixbrl::Fact.new(attributes)
    end
  end
end
