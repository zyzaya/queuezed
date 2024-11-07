class AddReviewDifficultToPracticeSession < ActiveRecord::Migration[7.2]
  def change
    add_column :practice_sessions, :review, :boolean, default: false
    add_column :practice_sessions, :difficult, :boolean, default: false
  end
end
