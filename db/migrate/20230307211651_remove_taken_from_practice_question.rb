class RemoveTakenFromPracticeQuestion < ActiveRecord::Migration[7.0]
  def change
    remove_column :practice_questions, :taken, :boolean
  end
end
