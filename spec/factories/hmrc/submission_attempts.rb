# frozen_string_literal: true

FactoryBot.define do
  factory :hmrc_submission_attempt, class: 'Hmrc::SubmissionAttempt' do
    submission_key do
      Digest::SHA256.hexdigest("ixbrl-payload:#{utr}")
    end

    status { :pending }

    utr { generate(:unique_utr) }

    hmrc_reference { nil }
    completed_at   { nil }

    failure_type   { nil }
    failure_status { nil }
    failure_body   { nil }

    trait :submitted do
      status { :submitted }
      hmrc_reference { 'ABC123456789' }
      completed_at { Time.current }
    end

    trait :failed do
      status { :failed }
      failure_type   { :hmrc_rejected_submission }
      failure_status { 400 }
      failure_body   { '<error/>' }
      completed_at { Time.current }
    end
  end
end
