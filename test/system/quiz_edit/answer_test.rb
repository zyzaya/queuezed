require "application_system_test_case"

class AnswerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def undo_action
    page.find("#undo").click
  end

  def redo_action
    page.find("#redo").click
  end

  def add_answer(single_question_edit)  
    button = single_question_edit.find(".add_answer")
    button.click
  end

  def get_answer_content(single_question_edit)
    single_question_edit.find_all(".answer_content").map do |e|
      e.text
    end
  end

  test "add answer -> undo -> redo" do
    quiz = quizzes(:johns)
    question = questions(:john_one)
    visit edit_quiz_path(quiz.id)
    select_question(question.id)
    single_question_edit = page.find(".single_question_edit[data-edit--single-question-id-value=\"#{question.id}\"]")
    initial_answers = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    result_answers = get_answer_content(single_question_edit)
    assert_equal initial_answers.length + 1, result_answers.length
    assert_equal [""], result_answers - initial_answers
    # undo
    undo_action
    result_answers = get_answer_content(single_question_edit)
    assert_equal initial_answers.length, result_answers.length
    assert_empty result_answers - initial_answers
    # redo
    redo_action
    result_answers = get_answer_content(single_question_edit)
    assert_equal initial_answers.length + 1, result_answers.length
    assert_equal [""], result_answers - initial_answers
  end
  # add answer -> undo -> redo
  # add answer -> switch selection -> undo -> redo
  # add answer -> undo -> switch selection -> redo
  # add answer -> save -> undo -> save -> redo -> save
  # delete answer
  # delete answer -> undo -> redo
  # delete answer -> switch selection -> undo -> redo
  # delete answer -> undo -> switch selection -> redo
  # delete answer -> save -> undo -> save -> redo -> save
  # change content
  # change content -> undo -> redo
  # change content -> switch selection -> undo -> redo
  # change content -> undo -> switch selection -> redo
  # change content -> save -> undo -> save -> redo -> save
end