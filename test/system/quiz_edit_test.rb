require "application_system_test_case"
require "test_helper"

class QuizEditTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @question = questions(:john_one)
    @initial_title = quizzes(:johns).name
    @modifier = "a"
    @modified_title = @initial_title + @modifier
    visit edit_quiz_path(quizzes(:johns))
  end  

  def change_title(modifier)
    input = page.find("#quiz_title")
    input.send_keys modifier
  end

  def assert_title(content)
    assert_selector("#quiz_title") { |t| t.value == content }
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
    assert_equal @question.content, textarea.value
    # answers
    expected_answers = @question.answers.pluck(:content)
    assert_equal expected_answers, get_answers_content
  end

  test "edit title -> undo -> redo" do
    change_title(@modifier)
    assert_title(@modified_title)
    # undo
    undo_action
    assert_title(@initial_title)
    # redo
    redo_action
    assert_title(@modified_title)
  end

  test "edit title -> save" do
    change_title(@modifier)
    assert_title(@modified_title)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    assert_title(@modified_title)
  end

  test "edit title -> save -> undo -> save" do
    change_title(@modifier)
    assert_title(@modified_title)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    assert_title(@initial_title)
  end

  test "edit title -> save -> undo -> save -> redo -> save" do
    change_title(@modifier)
    assert_title(@modified_title)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    assert_title(@modified_title)
  end
end