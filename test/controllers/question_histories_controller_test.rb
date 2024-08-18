require "test_helper"

class QuestionHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def submit_answer(id, text)
    practice_id = practice_sessions(:johns)
    params = { given: {} }
    q_id = Answer.find(id).question.id
    params[:given][q_id] = {}
    params[:given][q_id][id] = text
    post practice_answers_path(practice_id, params)
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
  test "create updates times taken" do
    question = questions(:john_one)
    initial = question.times_taken
    submit_answer(answers(:john_one).id, "given")
    assert_equal initial + 1, Question.find(question.id).times_taken
  end

  test "cannot access another users practice session with new" do
    get new_practice_answer_path(quizzes(:janes))
    assert_response :not_found
  end

  test "cannot access another users practice session with create" do
    post practice_answers_path(practice_sessions(:janes))
    assert_response :not_found
  end
end
