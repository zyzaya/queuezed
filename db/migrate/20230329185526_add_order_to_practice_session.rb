class AddOrderToPracticeSession < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_sessions, :order, :integer, array: true, default: []
  end
end
