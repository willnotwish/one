# frozen_string_literal: true

FactoryBot.define do
  factory :ct600_figures, class: 'Ct600::Figures' do
    non_trading_loan_profits_and_gains { 100 }
    losses_on_unquoted_shares { 0 }
    management_expenses { 20 }
    profits_before_other_deductions_and_reliefs { 100 }

    initialize_with do
      Ct600::Figures.new(attributes)
    end
  end
end
