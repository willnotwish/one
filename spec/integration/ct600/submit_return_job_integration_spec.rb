require "rails_helper"

module Ct600
  RSpec.describe SubmitReturnJob, type: :job do
    include ActiveJob::TestHelper

    let(:utr)   { FactoryBot.generate(:unique_utr) }

    before do
      Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
      Rails.logger.level = Logger::DEBUG
    end

    before do
      # OAuth token request
      stub_request(:post, Hmrc::OauthConfig.token_url)
        .to_return(
          status: 200,
          body: {
            access_token: "fake-token",
            token_type: "bearer",
            expires_in: 3600
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    describe 'happy path (successful submission)' do
      let(:ixbrl) { "<ixbrl>valid</ixbrl>" }
      let(:hmrc_reference) { "HMRC123" }
  
      before do
        stub_request(:post, "#{Hmrc::Ct600Config.submission_url}/#{utr}/returns")
          .to_return(
            status: 200,
            body: <<~XML,
              <Receipt>
                <ReceiptID>#{hmrc_reference}</ReceiptID>
              </Receipt>
            XML
            headers: { "Content-Type" => "application/xml" }
          )
      end

      it "submits a CT600 return and records the outcome" do
        perform_enqueued_jobs do
          described_class.perform_now(ixbrl:, utr:)
        end

        attempt = Hmrc::SubmissionAttempt.find_by(utr:)

        expect(attempt).to be_submitted
        expect(attempt.hmrc_reference).to eq(hmrc_reference)
        expect(attempt.completed_at).to be_within(1.second).of(Time.now)
      end
    end

    describe 'rejected by HMRC' do
      let(:ixbrl) { "<ixbrl>invalid</ixbrl>" }
  
      before do
        stub_request(:post, "#{Hmrc::Ct600Config.submission_url}/#{utr}/returns")
          .to_return(
            status: 400,
            body: "<Error>Rejected</Error>",
            headers: { "Content-Type" => "application/xml" }
          )
      end

      it 'records a failed outcome when HMRC rejects the submission' do
        perform_enqueued_jobs do
          described_class.perform_now(ixbrl:, utr:)
        end

        attempt = Hmrc::SubmissionAttempt.find_by(utr:)
        expect(attempt).to be_failed
        expect(attempt.failure_body).to include("Rejected")
        expect(attempt.completed_at).to be_within(1.second).of(Time.now)
      end
    end

    describe '500 server error from HMRC' do
      let(:ixbrl) { "<ixbrl>valid</ixbrl>" }

      before do
        stub_request(:post, "#{Hmrc::Ct600Config.submission_url}/#{utr}/returns")
          .to_return(
            status: 500,
            body: 'Foobar Error',
          )
      end

      it 'records a pending submission' do
        perform_enqueued_jobs do
          described_class.perform_now(ixbrl:, utr:)
        end

        attempt = Hmrc::SubmissionAttempt.find_by(utr:)
        expect(attempt).to be_awaiting_manual_resolution
      end
    end
  end
end
