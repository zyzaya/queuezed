class CreatePracticeQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :practice_questions do |t|
      t.integer :index
      t.belongs_to :practice_session, foreign_key: true
      t.belongs_to :question, foreign_key: true
      
      t.timestamps
    end
  end
end
