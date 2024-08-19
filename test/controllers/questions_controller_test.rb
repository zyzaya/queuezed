require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  # successful requests return json objects
  test "index returns json of questions" do
    quiz = quizzes(:johns)
    expected = quiz.questions.includes(:tags).as_json(include: :tags)
    get quiz_questions_path(quiz.id)
    assert_response :ok
    result = JSON.parse(@response.body)
    expected.each do |e|
      r = result.find { |f| f["id"] == e["id"] }
      r.each do |k, v|
        if r[k].nil?
          assert_nil e[k]
        else
          assert_equal r[k], e[k]
        end
      end
    end
  end

  test "new returns json of empty question" do
    quiz = quizzes(:johns)
    expected = quiz.questions.new.to_json.sub(/,"next_review":".+"/, "")

    get new_quiz_question_path(quiz.id)
    result = @response.body.sub(/,"next_review":".+"/, "")
    assert_response :ok
    assert_equal expected, result
  end

  test "new does not create a question" do
    quiz = quizzes(:johns)
    initial_count = quiz.questions.count

    get new_quiz_question_path(quiz.id)
    assert_equal initial_count, Quiz.find(quiz.id).questions.length
  end

  test "destroy returns json of the destroyed question" do
    question = questions(:john_one)
    expected = question.as_json
    delete "/questions/#{question.id}"
    result = JSON.parse(@response.body)
    assert_response :ok
    result.each do |k, v|
      if k.eql?("deleted_at")
        assert_not_nil v
      elsif result[k].nil?
        assert_not expected[k]
      else
        assert_equal result[k], expected[k]
      end
    end
  end

  test "destroy destroys question" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_count = quiz.questions.length
    delete "/questions/#{question.id}"
    assert_response :ok
    assert_equal initial_count - 1, Quiz.find(quiz.id).questions.length
  end

  # cannot access questions of another user
  test "cannot index questions of another user" do
    get quiz_questions_path(quizzes(:janes).id)
    assert_response :not_found
  end

  test "cannot edit question of another user" do
    get edit_question_path(questions(:jane_one).id)
    assert_response :not_found
  end

  test "cannot add question to the quiz of another user" do
    get new_quiz_question_path(questions(:jane_one).id)
    assert_response :not_found
  end

  test "cannot destroy question of another user" do
    delete "/questions/#{questions(:jane_one).id}"
    assert_response :not_found
  end
end
