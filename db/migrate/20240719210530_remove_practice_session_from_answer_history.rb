class RemovePracticeSessionFromAnswerHistory < ActiveRecord::Migration[7.0]
  def change
    remove_column :answer_histories, :practice_session_id
  end
end
