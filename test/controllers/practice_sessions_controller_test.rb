require "test_helper"

class PracticeSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def create_practice_session(text: "", tags: "", review: "")
    params = {
      text_filter: text,
      tag_filter: tags,
      review_filter: review
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
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
end
