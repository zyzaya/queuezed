class AddTakenToPracticeQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_questions, :taken, :boolean
  end
end
