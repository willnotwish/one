# frozen_string_literal: true

FactoryBot.define do
  factory :hmrc_submission_attempt, class: "Hmrc::SubmissionAttempt" do
    utr { "1234567890" }

    submission_key do
      Digest::SHA256.hexdigest("ixbrl-payload:#{utr}")
    end

    status { :pending }

    hmrc_reference { nil }
    submitted_at   { nil }

    failure_type   { nil }
    failure_status { nil }
    failure_body   { nil }

    trait :submitted do
      status { :submitted }
      hmrc_reference { "ABC123456789" }
      submitted_at { Time.current }
    end

    trait :failed do
      status { :failed }
      failure_type   { :hmrc_rejected_submission }
      failure_status { 400 }
      failure_body   { "<error/>" }
    end
  end
end
