require "test_helper"

class PracticeSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  test "new does not allow accessing another users quiz" do
    get new_quiz_practice_path(quizzes(:janes))
    assert_response :not_found
  end

  test "create does not allow accessing another users quiz" do
    post quiz_practice_index_path(quizzes(:janes))
    assert_response :not_found
  end

  test "show does not allow accesing another users practice session" do
    get practice_path(practice_sessions(:janes))
    assert_response :not_found
  end

  test "create creates new practice session" do
    quiz = quizzes(:johns)
    initial_count = quiz.practice_sessions.count
    params = {
      text_filter: "",
      tag_filter: "",
      review: "false"
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    result = Quiz.find(quiz.id)
    assert_equal initial_count + 1, result.practice_sessions.count
  end

  test "does not create practice session if no valid questions" do
    quiz = quizzes(:johns)
    initial_count = quiz.practice_sessions.count
    params = {
      text_filter: "no question has this text",
      tag_filter: "",
      review: false
    }
    post quiz_practice_index_path(quiz.id, params: params)
    result = Quiz.find(quiz.id)
    assert_equal initial_count, result.practice_sessions.count
  end
end
