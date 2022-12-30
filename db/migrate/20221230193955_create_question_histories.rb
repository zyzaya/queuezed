class CreateQuestionHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :question_histories do |t|
      t.integer :times_taken
      t.integer :times_correct
      t.belongs_to :question, foreign_key: true

      t.timestamps
    end
  end
end
