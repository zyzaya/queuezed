require "test_helper"

class PracticeSessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end
  
  test "new does not allow accessing another users quiz" do
    get new_quiz_practice_path(quizzes(:janes))
    assert_response :not_found
  end

  test "create does not allow accessing another users quiz" do
    post quiz_practice_index_path(quizzes(:janes))
    assert_response :not_found
  end

  test "show does not allow accesing another users practice session" do
    get practice_path(practice_sessions(:janes))
    assert_response :not_found
  end

  test "create obeys text filter" do
    text_filter = "holly"
    params = {
      text_filter: text_filter,
      tag_filter: "",
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    practice = PracticeSession.last
    practice.questions.each do |q|
      assert q.content.downcase.include?(text_filter)
    end
    excluded = quizzes(:johns).questions.where.not(id: practice.questions.ids)
    excluded.each do |q|
      assert_not q.content.downcase.include?(text_filter)
    end
  end

  test "create obeys tag filter" do
    tag_filter = "#{tags(:tag_1).id}"
    params = {
      text_filter: "",
      tag_filter: tag_filter
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    practice = PracticeSession.last
    practice.questions.each do |q|
      assert_not_nil q.tags.find_by(id: tags(:tag_1).id)
    end
    excluded = quizzes(:johns).questions.where.not(id: practice.questions.ids)
    excluded.each do |q|
      assert_nil q.tags.find_by(id: tags(:tag_1).id)
    end
  end

  test "create obeys review filter" do
    params = {
      text_filter: "",
      tag_filter: "",
      review_filter: "true"
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    practice = PracticeSession.last
    practice.questions.each do |q|
      assert q.review
    end
    excluded = quizzes(:johns).questions.where.not(id: practice.questions.ids)
    excluded.each do |q|
      assert_not q.review
    end
  end

  test "create does not include questions without an answer" do
    params = {
      text_filter: "",
      tag_filter: "",
      review_filter: "false"
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    practice = PracticeSession.last
    practice.questions.each do |q|
      assert q.answers.count > 0
    end
  end

  test "does not create a pracice session with no questions" do
    expected = PracticeSession.count
    params = {
      text_filter: "no questions have this text",
      tag_filter: "",
      review_filter: "false"
    }
    post quiz_practice_index_path(quizzes(:johns), params: params)
    assert_equal expected, PracticeSession.count
  end
  # create
  #   does not allow access to other users quizzes
  #   obeys text filter
  #   obeys tag filter
  #   obeys review filter
  #   does not include questions with not answer
  #   params permit/require
end
