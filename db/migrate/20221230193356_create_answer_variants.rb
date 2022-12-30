class CreateAnswerVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :answer_variants do |t|
      t.text :content
      t.belongs_to :answer, foreign_key: true

      t.timestamps
    end
  end
end
