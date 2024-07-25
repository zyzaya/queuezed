class AddRankToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :rank, :integer, default: 0
  end
end
