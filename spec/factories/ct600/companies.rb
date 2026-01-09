# frozen_string_literal: true

FactoryBot.define do
  factory :ct600_company, class: 'Ct600::Company' do
    name { Faker::Company.name }
    number { Faker::Number.leading_zero_number(digits: 8) }

    initialize_with do
      Ct600::Company.new(attributes)
    end
  end
end
