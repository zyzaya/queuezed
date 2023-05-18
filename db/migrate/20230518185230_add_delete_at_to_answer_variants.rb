class AddDeleteAtToAnswerVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :answer_variants, :deleted_at, :datetime
  end
end
