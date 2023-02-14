class CreateQuestionsRelationsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :questions_relations, id: false do |t|
      t.bigint :question_id
      t.bigint :relation_id
    end
  end
end
