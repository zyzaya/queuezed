class AddRanksToQuiz < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :rank_1_interval, :integer
    add_column :quizzes, :rank_2_interval, :integer
    add_column :quizzes, :rank_3_interval, :integer
    add_column :quizzes, :rank_4_interval, :integer
    add_column :quizzes, :rank_5_interval, :integer
  end
end
