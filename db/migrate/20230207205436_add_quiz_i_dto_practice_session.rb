class AddQuizIDtoPracticeSession < ActiveRecord::Migration[7.0]
  def change
    add_reference :practice_sessions, :quiz, foreign_key: true
  end
end
