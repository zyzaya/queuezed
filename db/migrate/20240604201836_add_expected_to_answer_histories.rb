class AddExpectedToAnswerHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :answer_histories, :expected, :string
  end
end
