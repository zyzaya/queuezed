class AddCorrectToAnswerHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :answer_histories, :correct, :boolean
  end
end
