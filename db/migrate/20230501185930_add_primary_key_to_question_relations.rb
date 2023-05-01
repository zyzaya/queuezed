class AddPrimaryKeyToQuestionRelations < ActiveRecord::Migration[7.0]
  def change
    add_column :question_relations, :id, :primary_key
  end
end
