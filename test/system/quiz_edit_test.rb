require "application_system_test_case"

class QuizEditTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end  

  test "initial load" do
    visit edit_quiz_path(quizzes(:johns))
    quiz = quizzes(:johns)
    body = page.find(".zg_body")
    expected_content = quiz.questions.pluck(:content)
    result_content = []
    body.assert_selector(".zg_row > .zg_td:first-child", count: quiz.questions.count) do |cell|
      result_content << cell.text
    end
    assert_empty expected_content - result_content
  end

  test "select question" do
    visit edit_quiz_path(quizzes(:johns))
    question = questions(:john_one)
    select_question(question.id)
    single_question_edit = page.find(".single_question_edit[data-single-question-id-value=\"#{question.id}\"]")
    # tags
    expected_tags = question.tags.pluck(:content)
    result_tags = []
    tag_list = page.find(".tag_list")
    tag_list.assert_selector("a", count: expected_tags.length) do |e|
      result_tags << e.text
    end
    assert_empty expected_tags - result_tags
    # question content
    textarea = single_question_edit.find(".question_content")
    assert_equal textarea.text, question.content
    # answers
    expected_answers = question.answers.pluck(:content)
    result_answers = []
    single_question_edit.assert_selector(".answer_content") do |e|
      result_answers << e.text
    end
    assert_empty expected_answers - result_answers
  end
end