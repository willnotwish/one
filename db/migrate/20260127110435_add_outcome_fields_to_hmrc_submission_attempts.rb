class AddOutcomeFieldsToHmrcSubmissionAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :hmrc_submission_attempts, :submitted_at, :datetime
    add_column :hmrc_submission_attempts, :failure_type, :string
    add_column :hmrc_submission_attempts, :failure_status, :integer
    add_column :hmrc_submission_attempts, :failure_body, :text
  end
end
