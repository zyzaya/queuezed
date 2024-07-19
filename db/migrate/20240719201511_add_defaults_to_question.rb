class AddDefaultsToQuestion < ActiveRecord::Migration[7.0]
  def change
    change_column :questions, :current_streak, :integer, default: 0
    change_column :questions, :longest_streak, :integer, default: 0
    change_column :questions, :times_taken, :integer, default: 0
    change_column :questions, :times_correct, :integer, default: 0
  end
end
