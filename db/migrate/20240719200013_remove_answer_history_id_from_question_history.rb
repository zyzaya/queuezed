class RemoveAnswerHistoryIdFromQuestionHistory < ActiveRecord::Migration[7.0]
  def change
    remove_column :question_histories, :answer_history_id
  end
end
