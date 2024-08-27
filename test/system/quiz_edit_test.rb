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
end