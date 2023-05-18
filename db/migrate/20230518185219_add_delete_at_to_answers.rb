class AddDeleteAtToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :deleted_at, :datetime
  end
end
