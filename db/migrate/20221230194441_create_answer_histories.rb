class CreateAnswerHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :answer_histories do |t|
      t.text :given
      t.text :correct
      t.belongs_to :answer, foreign_key: true

      t.timestamps
    end
  end
end
