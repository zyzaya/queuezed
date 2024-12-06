class AddNewColumnToQuestionsTag < ActiveRecord::Migration[7.2]
  def change
    add_column :questions_tags, :id, :primary_key
  end
end
