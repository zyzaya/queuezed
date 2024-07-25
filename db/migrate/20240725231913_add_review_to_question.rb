class AddReviewToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :review, :boolean
    add_column :questions, :next_review, :datetime
  end
end
