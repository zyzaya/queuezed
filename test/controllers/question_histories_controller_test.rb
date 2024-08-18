require "test_helper"

class QuestionHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def submit_answer(id, correct)
    practice_id = practice_sessions(:johns)
    params = { given: {} }
    answer = Answer.find(id)
    text = correct ? answer.content.split("/")[0].strip : ""
    q_id = answer.question.id
    params[:given][q_id] = {}
    params[:given][q_id][id] = text
    post practice_answers_path(practice_id, params)
  end

  test "create updates times taken" do
    question = questions(:john_one)
    initial = question.times_taken
    submit_answer(answers(:john_one).id, true)
    assert_equal initial + 1, Question.find(question.id).times_taken
  end

  test "create updates times_correct" do
    question = questions(:john_one)
    initial = question.times_correct
    submit_answer(answers(:john_one).id, true)
    assert_equal initial + 1, Question.find(question.id).times_correct
  end

  test "create updates current_streak" do
    question = questions(:john_one)
    initial = question.current_streak
    submit_answer(answers(:john_one).id, true)
    assert_equal initial + 1, Question.find(question.id).current_streak
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
