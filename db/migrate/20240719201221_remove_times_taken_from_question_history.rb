class RemoveTimesTakenFromQuestionHistory < ActiveRecord::Migration[7.0]
  def change
    remove_column :question_histories, :times_taken
  end
end
