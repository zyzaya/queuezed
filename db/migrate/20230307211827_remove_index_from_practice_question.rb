class RemoveIndexFromPracticeQuestion < ActiveRecord::Migration[7.0]
  def change
    remove_column :practice_questions, :index, :integer
  end
end
