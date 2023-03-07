class AddPracticeSessionIdtoAnswerHistory < ActiveRecord::Migration[7.0]
  def change
    add_reference :answer_histories, :practice_session, foreign_key: true
  end
end
