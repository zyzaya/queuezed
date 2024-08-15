require "test_helper"

class PracticeSessionsControllerTest < ActionDispatch::IntegrationTest
  # test "should get new" do
  #   get practice_session_new_url
  #   assert_response :success
  # end

  # new does not allow access to other users quizzes

  # create
  #   does not allow access to other users quizzes
  #   obeys text filter
  #   obeys tag filter
  #   obeys review filter
  #   does not include questions with not answer
end
