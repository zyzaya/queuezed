require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # successful requests return json objects
  test "index returns json of questions" do
    sign_in users(:john)
    get quiz_questions_path(1)
    expected = Quiz.find(1).questions.includes(:tags).to_json(include: :tags)

    assert_response :ok
    assert_equal expected, @response.body
  end

  test "new returns json of empty question" do
    sign_in users(:john)
    get new_quiz_question_path(1)
    expected = Quiz.find(1).questions.new.to_json
    expected = expected.sub(/,"next_review":".+"/, "")
    result = @response.body.sub(/,"next_review":".+"/, "")
    assert_response :ok
    assert_equal expected, result
  end

  test "new does not create a question" do
    sign_in users(:john)
    get new_quiz_question_path(1)
    assert_equal 2, Quiz.find(1).questions.length
  end

  test "destroy returns json of the destroyed question" do
    sign_in users(:john)
    expected = Question.find(1).to_json
    expected = expected.sub(/"deleted_at":null,/, "")
    delete "/questions/1"
    result = @response.body.sub(/"deleted_at":".+",/, "")
    assert_response :ok
    assert_equal expected, result
  end

  test "destroy destroys question" do
    sign_in users(:john)
    delete "/questions/1"
    assert_response :ok
    assert_equal 1, Quiz.find(1).questions.length
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
