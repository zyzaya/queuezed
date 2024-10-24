class ChangeTagFilterToArray < ActiveRecord::Migration[7.2]
  def change
    change_column :practice_sessions, :tag_filter, :integer, array: true, default: [], using: "tag_filter::integer[]"
  end
end
