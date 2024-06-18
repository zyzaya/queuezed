class AddQuestionCountToQuizzes < ActiveRecord::Migration[7.0]
  def change
    add_column :quizzes, :questions_count, :integer, default: 0, null: false

    Quiz.find_each { |quiz| Quiz.reset_counters(quiz.id, :questions)}
  end
end
