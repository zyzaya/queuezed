require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def update(quiz_id, body)
    patch "/quizzes/#{quiz_id}", params: body.to_json, headers: {'content-type': 'application/json'}
  end
  # update
  test "quiz title can be modified" do
    expected = "modified title"
    body = { quiz: {name: expected}}
    quiz = quizzes(:johns)
    update(quiz.id, body)
    assert_equal expected, Quiz.find(quiz.id).name
  end

  test "modify question content" do
    expected = "modified content"
    quiz = quizzes(:johns)
    question = questions(:john_one)
    body = { 
      quiz: {
        questions: [
          id: question.id,
          content: expected,
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal expected, Question.find(question.id).content
  end

  test "new question" do
    expected_content = "new question"
    quiz = quizzes(:johns)
    initial_count = quiz.questions.length
    body = {
      quiz: {
        questions: [
          content: expected_content,
          meta: "new"
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count + 1, Quiz.find(quiz.id).questions.length
    assert_not_nil Quiz.find(quiz.id).questions.find_by(content: expected_content)
  end

  test "delete question" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_count = quiz.questions.length
    body = {
      quiz: {
        questions: [
          id: question.id,
          meta: "delete"
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count - 1, Quiz.find(quiz.id).questions.length
    assert_nil Quiz.find(quiz.id).questions.find_by(id: question.id)
  end

  test "modify answer content" do
    expected = "modified content"
    quiz = quizzes(:johns)
    question = questions(:john_one)
    answer = answers(:john_one)
    body = {
      quiz: {
        questions: [
          id: question.id,
          answers: [
            id: answer.id,
            content: expected
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal expected, Answer.find(answer.id).content
  end

  test "new answer" do
    expected_content = "new answer"
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_count = question.answers.length
    body = {
      quiz: {
        questions: [
          id: question.id,
          answers: [
            content: expected_content,
            meta: "new"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count + 1, Question.find(question.id).answers.length
    assert_not_nil Question.find(question.id).answers.find_by(content: expected_content)
  end

  test "delete answer" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    answer = answers(:john_one)
    initial_count = question.answers.length
    body = {
      quiz: {
        questions: [
          id: question.id,
          answers: [
            id: answer.id,
            meta: "delete"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count - 1, Question.find(question.id).answers.length
    assert_nil Question.find(question.id).answers.find_by(id: answer.id)
  end

  test "new tag" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_count = question.tags.count
    expected_content = "new tag"
    body = {
      quiz: {
        questions: [
          id: question.id,
          tags: [
            meta: "new",
            content: expected_content
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count + 1, Question.find(question.id).tags.length
    assert_not_nil Question.find(question.id).tags.find_by(content: expected_content)
  end

  test "add tag" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    tag = tags(:tag_2)
    initial_count = question.tags.length
    body = {
      quiz: {
        questions: [
          id: question.id,
          tags: [
            meta: "add",
            id: tag.id
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count + 1, Question.find(question.id).tags.length
    assert_not_nil Question.find(question.id).tags.find_by(id: tag.id)
  end

  test "remove tag" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    tag = tags(:tag_1)
    initial_count = question.tags.length
    body = {
      quiz: {
        questions: [
          id: question.id,
          tags: [
            meta: "remove",
            id: tag.id
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_equal initial_count - 1, Question.find(question.id).tags.length
    assert_nil Question.find(question.id).tags.find_by(id: tag.id)
  end
  # invalid ids
  test "responds with 404 to invalid quiz id" do
    body = { quiz: { } }
    update(0, body)
    assert_response :not_found
  end

  test "responds with 404 to invalid question id" do
    quiz = quizzes(:johns)
    body = {
      quiz: {
        questions: [
          id: "invalid",
        ]
      }
    }
    update(quiz.id, body)
    assert_response :not_found
  end

  test "responds with 404 to invalid answer id" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    body = {
      quiz: {
        questions: [
          id: question.id,
          answers: [
            id: "invalid"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :not_found
  end

  test "responds with 404 to invalid tag id" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    body = {
      quiz: {
        questions: [
          id: question.id,
          tags: [
            id: "invalid"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :not_found
  end

  test "modifications do not occur of any id is invalid" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    answer = answers(:john_one)
    expected = quiz.name
    modified_name = "modified name"
    modified_content = "modified content"
    body = {
      quiz: {
        name: modified_name,
        questions: [
          id: question.id,
          content: modified_content,
          answers: [
            id: answer.id,
            content: modified_content
          ],
          tags: [
            id: "invalid",
            meta: "add",
            content: "invalid tag"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :not_found
    assert_equal quiz.to_json, Quiz.find(quiz.id).to_json
    assert_equal question.to_json, Question.find(question.id).to_json
    assert_equal answer.to_json, Answer.find(answer.id).to_json
  end
  # valid parameters
  # response

  # succesfull requests
  test "destroy destroys quiz" do
    delete "/quizzes/#{quizzes(:johns).id}"
    assert_equal 0, users(:john).quizzes.length
  end

  # cannot access quizzes of another user
  test "cannot edit a quiz of another user" do
    get edit_quiz_path(quizzes(:janes))
    assert_response :not_found
  end

  test "cannot destroy a quiz of another user" do
    delete "/quizzes/#{quizzes(:janes).id}"
    assert_response :not_found
  end

  test "cannot update a quiz of another user" do
    put "/quizzes/#{quizzes(:janes).id}"
    assert_response :not_found
  end
end
