class AddFilterToPracticeSession < ActiveRecord::Migration[7.0]
  def change
    add_column :practice_sessions, :tagFilter, :string
    add_column :practice_sessions, :textFilter, :string
  end
end
