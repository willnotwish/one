# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_27_110435) do
  create_table "hmrc_submission_attempts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "failure_body"
    t.integer "failure_status"
    t.string "failure_type"
    t.string "hmrc_reference"
    t.integer "status", null: false
    t.string "submission_key", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.string "utr", null: false
    t.index ["status"], name: "index_hmrc_submission_attempts_on_status"
    t.index ["submission_key"], name: "index_hmrc_submission_attempts_on_submission_key", unique: true
  end
end
