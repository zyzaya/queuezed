require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "cannot index question of another user" do
    puts User.all
  end

  ## cannot index question of another user
  ## cannot edit (?what is edit) question of another user
  ## cannot update question of another user
  ## cannot create question in the quiz of another user
  ## cannot destroy question of another user

  ## params for index, edit, update, new, destroy, only accept quiz_id
  ## index, update, new, destroy returns json of the question
end
