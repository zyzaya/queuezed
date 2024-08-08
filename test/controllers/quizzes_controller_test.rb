require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end
  # update
  test "quiz title can be modified" do
    expected = "modified title"
    body = { quiz: {name: expected}}
    patch "/quizzes/1", params: body.to_json, headers: {'content-type': 'application/json'}
    assert_equal expected, Quiz.find(1).name
  end


  # update
  # quiz title
  # questions
  #   new/edit/delete
  #   content
  #   answers
  #     new/edit/delete
  #     content
  #   tags
  #     new/edit/delete

  # succesfull requests
  test "destroy destroys quiz" do
    delete "/quizzes/1"
    assert_equal 0, users(:john).quizzes.length
  end

  # cannot access quizzes of another user
  test "cannot edit a quiz of another user" do
    get edit_quiz_path(2)
    assert_response :not_found
  end

  test "cannot destroy a quiz of another user" do
    delete "/quizzes/2"
    assert_response :not_found
  end

  test "cannot update a quiz of another user" do
    put "/quizzes/2"
    assert_response :not_found
  end
end
