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

ActiveRecord::Schema[7.0].define(version: 2024_07_25_220633) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answer_histories", force: :cascade do |t|
    t.text "given"
    t.bigint "answer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "expected"
    t.boolean "correct"
    t.bigint "question_history_id", null: false
    t.index ["answer_id"], name: "index_answer_histories_on_answer_id"
    t.index ["question_history_id"], name: "index_answer_histories_on_question_history_id"
  end

  create_table "answers", force: :cascade do |t|
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.text "content"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "practice_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "quiz_id"
    t.integer "length"
    t.integer "current"
    t.integer "order", default: [], array: true
    t.string "tag_filter"
    t.string "text_filter"
    t.index ["quiz_id"], name: "index_practice_sessions_on_quiz_id"
  end

  create_table "question_histories", force: :cascade do |t|
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "correct"
    t.bigint "practice_session_id", null: false
    t.index ["practice_session_id"], name: "index_question_histories_on_practice_session_id"
    t.index ["question_id"], name: "index_question_histories_on_question_id"
  end

  create_table "question_relations", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "relation_id"
    t.datetime "deleted_at"
  end

  create_table "questions", force: :cascade do |t|
    t.text "content"
    t.integer "current_streak", default: 0
    t.integer "longest_streak", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "last_taken"
    t.integer "times_taken", default: 0
    t.integer "times_correct", default: 0
    t.bigint "quiz_id", null: false
    t.integer "rank", default: 0
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "questions_tags", id: false, force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "tag_id", null: false
    t.index ["question_id"], name: "index_questions_tags_on_question_id"
    t.index ["tag_id"], name: "index_questions_tags_on_tag_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "questions_count", default: 0, null: false
    t.integer "rank_1_interval"
    t.integer "rank_2_interval"
    t.integer "rank_3_interval"
    t.integer "rank_4_interval"
    t.integer "rank_5_interval"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answer_histories", "answers"
  add_foreign_key "answer_histories", "question_histories"
  add_foreign_key "answers", "questions"
  add_foreign_key "practice_sessions", "quizzes"
  add_foreign_key "question_histories", "practice_sessions"
  add_foreign_key "question_histories", "questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "users"
end
