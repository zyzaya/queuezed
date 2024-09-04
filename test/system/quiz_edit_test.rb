require "application_system_test_case"
require "test_helper"

class QuizEditTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @question = questions(:john_one)
    visit edit_quiz_path(quizzes(:johns))
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
    select_question(@question.id)
    # tags
    expected_tags = @question.tags.pluck(:content)
    assert_equal expected_tags, get_tags_content
    # question content
    textarea = single_question_edit_container(@question.id).find(".question_content")
    assert_equal textarea.text, @question.content
    # answers
    expected_answers = @question.answers.pluck(:content)
    assert_equal expected_answers, get_answers_content
  end
end