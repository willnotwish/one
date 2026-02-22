# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/ct600_submission_succeeded
  def ct600_submission_succeeded
    UserMailer.ct600_submission_succeeded
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/ct600_submission_failed
  def ct600_submission_failed
    UserMailer.ct600_submission_failed
  end

end
