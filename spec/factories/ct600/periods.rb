# frozen_string_literal: true

FactoryBot.define do
  factory :ct600_period, class: 'Ct600::Period' do
    starts_on { Date.new(2024, 4, 1) }
    ends_on { Date.new(2025, 3, 31) }

    initialize_with do
      Ct600::Period.new(attributes)
    end
  end
end
