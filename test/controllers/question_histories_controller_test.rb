require "test_helper"

class QuestionHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end
  # does not allow access to another users stuff
  # strong parameters
  # new: 
  # create: 
  #  modifies statistics
  #   times_taken
  #   last_taken
  #   times_correct
  #   current_streak
  #   srs_rank
  #   difficult
  #   rank
  #   review
  #  creates answer histories


  test "cannot access another users practice session with new" do
    get new_practice_answer_path(quizzes(:janes))
    assert_response :not_found
  end

  test "cannot access another users practice session with create" do
    post practice_answers_path(practice_sessions(:janes))
    assert_response :not_found
  end
end
