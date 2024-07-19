class RenameFilterColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :practice_sessions, :tagFilter, :tag_filter
    rename_column :practice_sessions, :textFilter, :text_filter
  end
end
