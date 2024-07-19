class AddCorrectToQuestionHistory < ActiveRecord::Migration[7.0]
  def change
    add_column :question_histories, :correct, :boolean
  end
end
