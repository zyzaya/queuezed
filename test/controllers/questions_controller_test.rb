require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # successful requests return json objects
  test "index returns json of question" do
    sign_in users(:john)
    get quiz_questions_path(1)
    expected = Quiz.find(1).questions.includes(:tags).to_json(include: :tags)

    assert_response :ok
    assert_equal expected, @response.body
  end

  # cannot access questions of another user
  test "cannot index questions of another user" do
    sign_in users(:john)
    get quiz_questions_path(2)
    assert_response :not_found
  end

  test "cannot edit question of another user" do
    sign_in users(:john)
    get edit_question_path(3)
    assert_response :not_found
  end

  test "cannot update question of another user" do
    sign_in users(:john)
    patch "/questions/3"
    assert_response :not_found
  end

  test "cannot add question to the quiz of another user" do
    sign_in users(:john)
    get new_quiz_question_path(2)
    assert_response :not_found
  end

  test "cannot destroy question of another user" do
    sign_in users(:john)
    delete "/questions/3"
    assert_response :not_found
  end

  # only valid params allowed
  ## params for index, edit, update, new, destroy, only accept quiz_id
end
