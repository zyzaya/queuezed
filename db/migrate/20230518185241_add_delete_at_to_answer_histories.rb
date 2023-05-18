class AddDeleteAtToAnswerHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :answer_histories, :deleted_at, :datetime
  end
end
