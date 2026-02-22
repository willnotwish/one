# frozen_string_literal: true

require "rails_helper"

module Hmrc
  module Submissions
    RSpec.describe ResponseParser do
      subject(:parser) { described_class.new }

      describe "#call" do
        context "when HMRC responds with a successful status and a receipt reference" do
          let(:raw_response) do
            {
              status: 200,
              body: <<~XML
                <SubmissionResponse>
                  <ReceiptID>ABC123456789</ReceiptID>
                </SubmissionResponse>
              XML
            }
          end

          it "returns Success with the parsed response" do
            result = parser.call(raw_response)

            expect(result).to be_success
            expect(result.value!).to eq(
              status: 200,
              hmrc_reference: "ABC123456789",
              body: raw_response[:body]
            )
          end
        end

        context "when HMRC responds with a 2xx status but no receipt reference" do
          let(:raw_response) do
            {
              status: 200,
              body: "<SubmissionResponse></SubmissionResponse>"
            }
          end

          it "returns a failure indicating an invalid success response" do
            result = parser.call(raw_response)

            expect(result).to be_failure
            expect(result.failure).to include(
              type: :hmrc_invalid_success_response,
              status: 200,
              body: raw_response[:body]
            )
          end
        end

        context "when HMRC rejects the submission with a client error" do
          let(:raw_response) do
            {
              status: 400,
              body: "<Error>Bad Request</Error>"
            }
          end

          it "returns a failure indicating rejection" do
            result = parser.call(raw_response)

            expect(result).to be_failure
            expect(result.failure).to include(
              type: :hmrc_rejected_submission,
              status: 400,
              body: raw_response[:body]
            )
          end
        end

        context "when HMRC responds with a server error" do
          let(:raw_response) do
            {
              status: 500,
              body: "<Error>Internal Server Error</Error>"
            }
          end

          it "returns a failure indicating rejection" do
            result = parser.call(raw_response)

            expect(result).to be_failure
            expect(result.failure).to include(
              type: :hmrc_rejected_submission,
              status: 500,
              body: raw_response[:body]
            )
          end
        end
      end
    end
  end
end
