class RemoveQuizFromQuestion < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :quiz_id, :integer
  end
end
