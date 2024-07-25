class DropSrsBox < ActiveRecord::Migration[7.0]
  def change
    drop_table :srs_boxes
  end
end
