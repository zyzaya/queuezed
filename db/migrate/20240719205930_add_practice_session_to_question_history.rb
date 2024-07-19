class AddPracticeSessionToQuestionHistory < ActiveRecord::Migration[7.0]
  def change
    add_reference :question_histories, :practice_session, null: false, foreign_key: true
  end
end
