class DropPracticeQuestions < ActiveRecord::Migration[7.0]
  def change
    drop_table :practice_questions do |t|
      t.belongs_to :practice_session, foreign_key: true
      t.belongs_to :question, foreign_key: true
      
      t.timestamps
    end
  end
end
