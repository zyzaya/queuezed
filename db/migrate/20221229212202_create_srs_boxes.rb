class CreateSrsBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :srs_boxes do |t|
      t.integer :rank
      t.time :interval
      t.belongs_to :quiz, foreign_key: true

      t.timestamps
    end
  end
end
