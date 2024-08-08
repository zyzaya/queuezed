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

  test "modify question content" do
    expected = "modified content"
    body = { 
      quiz: {
        questions: [
          id: 1,
          content: expected,
        ]
      }
    }
    patch "/quizzes/1", params: body.to_json, headers: {'content-type': 'application/json'}
    assert_equal expected, Question.find(1).content
  end

  test "new question" do
    expected_content = "new question"
    body = {
      quiz: {
        questions: [
          content: expected_content,
          meta: "new"
        ]
      }
    }
    patch "/quizzes/1", params: body.to_json, headers: {'content-type': 'application/json'}
    assert_equal 3, Quiz.find(1).questions.length
    assert_not_nil Quiz.find(1).questions.find_by(content: expected_content)
  end

  test "delete question" do
    body = {
      quiz: {
        questions: [
          id: 1,
          meta: "delete"
        ]
      }
    }
    patch "/quizzes/1", params: body.to_json, headers: {'content-type': 'application/json'}
    assert_equal 1, Quiz.find(1).questions.length
    assert_nil Quiz.find(1).questions.find_by(id: 1)
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
  #     new/add/remove

  # nonexistant ids

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
