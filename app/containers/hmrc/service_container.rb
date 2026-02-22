# frozen_string_literal: true

module Hmrc
  # app/containers/hmrc_container.rb
  class ServiceContainer
    extend Dry::Container::Mixin

    register(:oauth_client) { OauthApiClient.new }
    register(:submission_client) { Ct600::SubmissionApiClient.new }

    namespace(:submissions) do
      register(:attempt_loader) { Submissions::AttemptLoader.new }
      register(:idempotency_guard) { Submissions::IdempotencyGuard.new }
      register(:outcome_recorder) { Submissions::OutcomeRecorder.new }
      register(:response_parser) { Submissions::ResponseParser.new }
      register(:submitted_verifier) { Submissions::SubmittedVerifier.new }
    end
  end
end
