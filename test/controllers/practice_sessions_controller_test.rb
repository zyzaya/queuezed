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

  # create
  #   does not allow access to other users quizzes
  #   obeys text filter
  #   obeys tag filter
  #   obeys review filter
  #   does not include questions with not answer
end
