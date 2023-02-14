class RemoveCurrentIndexFromPracticeSessions < ActiveRecord::Migration[7.0]
  def change
    remove_column :practice_sessions, :current_index
  end
end
