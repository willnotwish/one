class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.ct600_submission_succeeded.subject
  #
  def ct600_submission_succeeded(attempt)
    @attempt = attempt
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.ct600_submission_failed.subject
  #
  def ct600_submission_failed(attempt)
    @attempt = attempt
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
