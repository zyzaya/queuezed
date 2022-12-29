class AddQuestionToSrsBox < ActiveRecord::Migration[7.0]
  def change
    add_reference :questions, :srs_box, foreign_key: true
  end
end
