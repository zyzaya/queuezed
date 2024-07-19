class AddStatisticsToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :last_taken, :datetime
    add_column :questions, :times_taken, :integer
    add_column :questions, :times_correct, :integer

    remove_column :question_histories, :times_correct, :times_taken
  end
end
