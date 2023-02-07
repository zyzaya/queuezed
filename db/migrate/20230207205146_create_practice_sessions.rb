class CreatePracticeSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :practice_sessions do |t|
      t.integer :current_index

      t.timestamps
    end
  end
end
