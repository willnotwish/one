require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "ct600_submission_succeeded" do
    let(:mail) { UserMailer.ct600_submission_succeeded }

    it "renders the headers" do
      expect(mail.subject).to eq("Ct600 submission succeeded")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "ct600_submission_failed" do
    let(:mail) { UserMailer.ct600_submission_failed }

    it "renders the headers" do
      expect(mail.subject).to eq("Ct600 submission failed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
