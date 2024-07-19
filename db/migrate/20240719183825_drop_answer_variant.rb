class DropAnswerVariant < ActiveRecord::Migration[7.0]
  def change
    drop_table :answer_variants
  end
end
