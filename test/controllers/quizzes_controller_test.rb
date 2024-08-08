require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
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
  # new does not create


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
end
