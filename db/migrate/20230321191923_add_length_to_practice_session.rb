class AddLengthToPracticeSession < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_sessions, :length, :integer
  end
end
