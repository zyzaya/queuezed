class AddDeletedAtToQuestionHistory < ActiveRecord::Migration[7.2]
  def change
    add_column :question_histories, :deleted_at, :datetime
  end
end
