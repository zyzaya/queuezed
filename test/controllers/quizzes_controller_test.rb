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
            id: "temp1",
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

  test "add relation" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    relation = questions(:john_two)
    body = {
      quiz: {
        questions: [
          id: question.id,
          relations: [
            id: relation.id,
            meta: "add"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert Question.find(question.id).relations.include?(Question.find(relation.id))
  end

  test "remove relation" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    relation = questions(:john_two)
    question.relations << relation
    body = {
      quiz: {
        questions: [
          id: question.id,
          relations: [
            id: relation.id,
            meta: "remove"
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    assert_not Question.find(question.id).relations.include?(Question.find(relation.id))
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
    modified_name = "modified name"
    modified_content = "modified content"
    body = {
      quiz: {
        name: modified_name,
        questions: [
          id: question.id,
          content: modified_content,
          answers: [
            id: "invalid",
            content: modified_content
          ]
        ]
      }
    }
    update(quiz.id, body)
    assert_response :not_found
    assert_equal Quiz.find(quiz.id).to_json, quiz.to_json
    assert_equal Question.find(question.id).to_json, question.to_json
    assert_equal Answer.find(answer.id).to_json, answer.to_json
  end
  # response
  test "responds with json of the quiz, including tags and answers" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    answer = answers(:john_one)
    modified_content = "modified_content"
    body = {
      quiz: {
        name: "modified content",
        questions: [
          {
            id: question.id,
            content: modified_content,
            answers: [
              id: answer.id,
              content: modified_content
            ]
          },
          {
            id: questions(:john_two).id,
            meta: 'delete'
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = JSON.parse(@response.body)
    expected = Quiz.find(quiz.id).as_json(
      only: [:name],
      include: {
        questions: {
          include: {
            answers: {
              only: [:id, :content]
            },
            tags: {
              only: [:id, :content]
            }
          }
        }
      }
    )
    assert_equal(
      expected, 
      result,
      "expected:\n#{JSON.pretty_generate(expected)}\nactual:\n#{JSON.pretty_generate(result)}}"
    )
  end
  # temp ids
  test "converts temp question id into real id" do
    quiz = quizzes(:johns)
    initial_id = "temp1"
    initial_content = "initial content"
    body = {
      quiz: {
        questions: [
          {
            id: initial_id,
            meta: 'new',
            content: initial_content,
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = JSON.parse(response.body)
    question = result["questions"].find { |q| q["prev_id"].eql?(initial_id) }
    assert_equal initial_content, question["content"]
    assert_equal Question.find(question["id"]).content, question["content"]
  end

  test "converts temp answer id into real id" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_id = "temp1"
    initial_content = "initial_content"
    body = {
      quiz: {
        questions: [
          {
            id: question.id,
            answers: [
              {
                meta: 'new',
                id: initial_id,
                content: initial_content,
              }
            ]
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = JSON.parse(response.body)
    result_question = result["questions"].find { |q| q["id"].eql?(question.id) }
    result_answer = result_question["answers"].find { |a| a["prev_id"].eql?(initial_id) }
    assert_equal initial_content, result_answer["content"]
    assert_equal Answer.find(result_answer["id"]).content, result_answer["content"]
  end

  test "converts temp tag id into real id" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    initial_id = "temp1"
    initial_content = "initial_content"
    body = {
      quiz: {
        questions: [
          {
            id: question.id,
            tags: [
              {
                meta: "new",
                id: initial_id,
                content: initial_content,
              }
            ]
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = JSON.parse(response.body)
    result_question = result["questions"].find { |q| q["id"].eql?(question.id) }
    result_tag = result_question["tags"].find { |t| t["prev_id"].eql?(initial_id) }
    assert_equal result_tag["content"], initial_content
    assert_equal result_tag["content"], Tag.find(result_tag["id"]).content
  end

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

  test "add relation to newly created questions" do
    quiz = quizzes(:johns)
    content_1 = "test1"
    content_2 = "test2"
    body = {
      quiz: {
        questions: [
          {
            id: 'n1',
            content: content_1,
            meta: 'new',
            relations: [
              id: 'n2',
              meta: 'add'
            ]
          },
          {
            id: 'n2',
            content: content_2,
            meta: 'new',
            relations: [
              id: 'n1',
              meta: 'add'
            ]
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    q1 = quiz.questions.find_by(content: content_1)
    q2 = quiz.questions.find_by(content: content_2)
    assert_not_nil q1.relations.find_by(content: content_2)
    assert_not_nil q2.relations.find_by(content: content_1)
  end

  test "add newly created tag to newly created questions" do
    tag_content = "t1"
    initial_tag_id = 'n4'
    initial_q_ids = ["n1", "n2", "n3"]
    quiz = quizzes(:johns)
    initial_tags = quiz.tags.pluck(:content).sort
    body = {
      quiz:{
        questions: [
          {
            id: initial_q_ids[0],
            content: 'one',
            meta: 'new',
            tags: [
              {
                id: initial_tag_id,
                content: tag_content,
                meta: 'new'
              }
            ]
          },
          {
            id: initial_q_ids[1],
            content: 'two',
            meta: 'new',
            tags: [
              {
                id: initial_tag_id,
                content: tag_content,
                meta: 'add'
              }
            ]
          },
          {
            id: initial_q_ids[2],
            content: 'three',
            meta: 'new',
            tags: [
              id: initial_tag_id,
              content: tag_content,
              meta: 'add'
            ]
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = JSON.parse(response.body)
    assert_equal (initial_tags + [tag_content]).sort, quiz.tags.pluck(:content).sort
    tag = quiz.tags.find_by(content: tag_content)
    tag_id = tag.id
    questions = result["questions"].find_all { |q| initial_q_ids.include?(q["prev_id"]) }
    q_ids = questions.map { |q| q["id"] }
    assert_equal q_ids, Tag.find(tag_id).questions.pluck(:id)
  end

  test "soft destroy" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    body = {
      quiz: {
        questions: [
          {
            id: question.id,
            meta: 'delete'
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    result = Question.find(question.id)
    assert_not_nil result.deleted_at
  end

  test "restore" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    body = {
      quiz: {
        questions: [
          {
            id: question.id,
            meta: 'delete'
          }
        ]
      }
    }
    update(quiz.id, body)
    assert_response :ok
    body = {
      quiz: {
        questions: [
          {
            id: question.id,
            meta: 'new'
          }
        ]
      }
    }
    update(quiz.id, body)
    result = Question.find(question.id)
    assert_nil result.deleted_at
  end
end
