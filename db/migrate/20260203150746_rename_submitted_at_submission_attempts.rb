class RenameSubmittedAtSubmissionAttempts < ActiveRecord::Migration[8.1]
  def change
    rename_column :hmrc_submission_attempts, :submitted_at, :completed_at
  end
end
