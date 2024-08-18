class AddDifficultToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :difficult, :boolean, default: false
  end
end
