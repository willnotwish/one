# frozen_string_literal: true

FactoryBot.define do
  factory :ct600_submission, class: 'Ct600::Submission' do
    company factory: :ct600_company
    period factory: :ct600_period
    figures factory: :ct600_figures

    initialize_with do
      Ct600::Submission.new(attributes)
    end
  end
end
