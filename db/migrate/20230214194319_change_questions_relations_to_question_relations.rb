class ChangeQuestionsRelationsToQuestionRelations < ActiveRecord::Migration[7.0]
  def change
    rename_table :questions_relations, :question_relations
  end
end
