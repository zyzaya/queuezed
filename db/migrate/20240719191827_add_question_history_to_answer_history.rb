class AddQuestionHistoryToAnswerHistory < ActiveRecord::Migration[7.0]
  def change
    add_reference :answer_histories, :question_history, null: false, foreign_key: true
  end
end
