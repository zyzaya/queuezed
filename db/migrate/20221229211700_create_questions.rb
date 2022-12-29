class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.integer :current_streak
      t.integer :longest_streak

      t.timestamps
    end
  end
end
