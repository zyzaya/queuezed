class RemoveContentFromAnswer < ActiveRecord::Migration[7.0]
  def change
    remove_column :answers, :content, :text
  end
end
