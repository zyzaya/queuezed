require "application_system_test_case"
require "test_helper"

class AnswerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @answer = answers(:john_one)
    @modify_content = "a"
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    @initial = get_answers_content
  end

  def add_answer  
    container = single_question_edit_container(@question.id)
    button = container.find(".add_answer")
    button.click
  end

  def delete_answer(id)
    container = answer_container(id)
    button = container.find(".delete_answer")
    button.click
  end

  def change_answer_content(id)
    textarea = answer_container(id).find("textarea")
    textarea.send_keys(@modify_content)
  end

  def get_answers_content
    container = single_question_edit_container(@question.id)
    container.find_all(".answer_content").map do |e|
      e.value
    end
  end

  def assert_answer_content(id, content)
    textarea = answer_container(id).find("textarea")
    assert_equal content, textarea.value
  end

  def assert_add_answer
    assert_equal @initial + [""], get_answers_content
  end

  def assert_delete_answer(content)
    assert_equal @initial - [content], get_answers_content
  end

  def assert_no_change_to_answers
    assert_equal @initial, get_answers_content
  end

  test "add answer -> undo -> redo" do
    # add answer
    add_answer
    assert_add_answer
    # undo
    undo_action
    assert_no_change_to_answers
    # redo
    redo_action
    assert_add_answer
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
    question = questions(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # add answer
    add_answer(single_question_edit)
    assert_add_answer(initial, single_question_edit)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_add_answer(initial, single_question_edit)
  end

  test "delete answer -> undo -> redo" do
    question = questions(:john_one)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer
    delete_answer(answer.id)
    assert_delete_answer(initial, answer, single_question_edit)
    # undo
    undo_action
    assert_no_change_to_answers(initial, single_question_edit)
    # redo
    redo_action
    assert_delete_answer(initial, answer, single_question_edit)
  end

  test "delete answer -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer
    delete_answer(answer.id)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_no_change_to_answers(initial, single_question_edit)
    # redo
    redo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_delete_answer(initial, answer, single_question_edit)
  end

  test "delete answer -> undo -> switch selection -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer -> undo -> switch selection
    delete_answer(answer.id)
    undo_action
    # switch selection
    select_question(other.id)
    # redo
    redo_action
    single_question_edit = single_question_edit_container(question.id)
    assert_delete_answer(initial, answer, single_question_edit)
  end

  test "delete answer -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer
    delete_answer(answer.id)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_delete_answer(initial, answer, single_question_edit)
  end

  test "delete answer -> save -> undo -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer
    delete_answer(answer.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_no_change_to_answers(initial, single_question_edit)
  end

  test "delete answer -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    initial = get_answer_content(single_question_edit)
    # delete answer
    delete_answer(answer.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    single_question_edit = single_question_edit_container(question.id)
    assert_delete_answer(initial, answer, single_question_edit)
  end

  test "change answer content -> undo -> redo" do
    question = questions(:john_one)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = answer.content
    modify = "a"
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # undo
    undo_action
    assert_answer_content(answer.id, initial)
    # redo
    redo_action
    assert_answer_content(answer.id, initial + modify)
  end

  test "change answer content -> switch selection -> undo -> redo" do
    question = questions(:john_one)
    other = questions(:john_two)
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    initial = answer.content
    modify = "a"
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # switch selection
    select_question(other.id)
    # undo
    undo_action
    assert_answer_content(answer.id, initial)
    # redo
    redo_action
    assert_answer_content(answer.id, initial + modify)
  end

  test "change answer content -> undo -> switch selection -> redo" do
    answer = answers(:john_one)
    visit edit_quiz_path(quizzes(:johns))
    select_question(questions(:john_one).id)
    initial = answer.content
    modify = "a"
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # undo
    undo_action
    assert_answer_content(answer.id, initial)
    # switch selection
    select_question(questions(:john_two).id)
    # redo
    redo_action
    assert_answer_content(answer.id, initial + modify)
  end

  test "change answer content -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    initial = answer.content
    modify = "a"
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_answer_content(answer.id, initial + modify)
  end

  test "change answer content -> save -> undo -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    initial = answer.content
    modify = "a"
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_answer_content(answer.id, initial)
  end

  test "change answer content -> save -> undo -> save -> redo -> save" do
    question = questions(:john_one)
    answer = answers(:john_one)
    initial = answer.content
    modify = "a"
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    # change content
    change_answer_content(answer.id, modify)
    assert_answer_content(answer.id, initial + modify)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(question.id)
    assert_answer_content(answer.id, initial + modify)
  end
end