require "test_helper"

class QuestionHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def submit_answers(question, correct)
    params = { given: {} }
    params[:given][question.id] = []
    question.answers.each do |a|
      params[:given][question.id] << a.variants[0]
    end
    post practice_answers_path(practice_sessions(:johns), params)
  end

  test "create updates statistics" do
    question = questions(:john_one)
    initial_times_taken = question.times_taken
    initial_times_correct = question.times_correct
    initial_current_streak = question.current_streak
    submit_answers(question, true)
    result = Question.find(question.id)
    assert_equal initial_times_taken + 1, result.times_taken
    assert_equal initial_times_correct + 1, result.times_correct
    assert_equal initial_current_streak + 1, result.current_streak
  end

  test "cannot access another users practice session with new" do
    get new_practice_answer_path(quizzes(:janes))
    assert_response :not_found
  end

  test "cannot access another users practice session with create" do
    post practice_answers_path(practice_sessions(:janes))
    assert_response :not_found
  end
end
