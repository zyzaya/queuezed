class AddCurrentToPracticeSession < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_sessions, :current, :integer
  end
end
