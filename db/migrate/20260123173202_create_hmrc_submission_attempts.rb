# frozen_string_literal: true

# SubmissionAttempt model migration
class CreateHmrcSubmissionAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :hmrc_submission_attempts do |t|
      t.string :submission_key, null: false
      t.string :utr, null: false
      t.integer :status, null: false
      t.string :hmrc_reference

      t.timestamps
    end

    add_index :hmrc_submission_attempts, :submission_key, unique: true
    add_index :hmrc_submission_attempts, :status
  end
end
