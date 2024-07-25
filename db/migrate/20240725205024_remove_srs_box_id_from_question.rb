class RemoveSrsBoxIdFromQuestion < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :srs_box_id
  end
end
