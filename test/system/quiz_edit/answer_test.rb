require "application_system_test_case"

class AnswerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
  end

  def save_action
    page.find("#save").click
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

  def assert_add_answer(initial, single_question_edit)
    result = get_answer_content(single_question_edit)
    assert_equal initial.length + 1, result.length
    assert_equal [""], result - initial
  end

  def assert_no_change_to_answers(initial, single_question_edit)
    result = get_answer_content(single_question_edit)
    assert_equal initial.length, result.length
    assert_empty result - initial
    assert_empty initial - result
  end

  test "add answer -> undo -> redo" do
    question = questions(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # undo
    undo_action
    assert_no_change_to_answers(initial, single_question_edit)
    # redo
    redo_action
    assert_add_answer(initial, single_question_edit)
    result_answers = get_answer_content(single_question_edit)
  end

  test "add answer -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_no_change_to_answers(initial, single_question_edit)
    # redo
    redo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_add_answer(initial, single_question_edit)
  end

  test "add answer -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # undo
    undo_action
    assert_no_change_to_answers(initial, single_question_edit)
    # switch selection
    select_question(other.id)
    # redo
    redo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_add_answer(initial, single_question_edit)
  end

  test "add answer -> save" do
    question = questions(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_add_answer(initial, single_question_edit)
  end

  test "add answer -> save -> undo -> save" do
    question = questions(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_no_change_to_answers(initial, single_question_edit)
  end

  test "add answer -> save -> undo -> save -> redo -> save" do
  
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