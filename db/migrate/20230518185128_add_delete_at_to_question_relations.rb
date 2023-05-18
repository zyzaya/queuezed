class AddDeleteAtToQuestionRelations < ActiveRecord::Migration[7.0]
  def change
    add_column :question_relations, :deleted_at, :datetime
  end
end
