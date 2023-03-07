class RemoveCorrectFromAnswerHistory < ActiveRecord::Migration[7.0]
  def change
    remove_column :answer_histories, :correct, :text
  end
end
