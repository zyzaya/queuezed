require "application_system_test_case"
require "test_helper"

class AnswerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @answer = answers(:john_one)
    @initial_answer_content = @answer.content
    @modify_content = "a"
    @modified_answer_content = @initial_answer_content + @modify_content
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

  def change_answer_content(id, modify)
    textarea = answer_container(id).find("textarea")
    textarea.send_keys(modify)
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
    # add answer
    add_answer
    assert_add_answer
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_answers
    # redo
    redo_action
    assert_add_answer
  end

  test "add answer -> undo -> switch selection -> redo" do
    # add answer
    add_answer
    assert_add_answer
    # undo
    undo_action
    assert_no_change_to_answers
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_add_answer
  end

  test "add answer -> save" do
    # add answer
    add_answer
    assert_add_answer
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_add_answer
  end

  test "add answer -> save -> undo -> save" do
    # add answer
    add_answer
    assert_add_answer
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_no_change_to_answers
  end

  test "add answer -> save -> undo -> save -> redo -> save" do
    # add answer
    add_answer
    assert_add_answer
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_add_answer
  end

  test "delete answer -> undo -> redo" do
    # delete answer
    delete_answer(@answer.id)
    assert_delete_answer(@answer.content)
    # undo
    undo_action
    assert_no_change_to_answers
    # redo
    redo_action
    assert_delete_answer(@answer.content)
  end

  test "delete answer -> switch selection -> undo -> redo" do
    # delete answer
    delete_answer(@answer.id)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_answers
    # redo
    redo_action
    assert_delete_answer(@answer.content)
  end

  test "delete answer -> undo -> switch selection -> redo" do
    # delete answer -> undo -> switch selection
    delete_answer(@answer.id)
    undo_action
    # switch selection
    select_question(@other.id)
    # redo
    redo_action
    assert_delete_answer(@answer.content)
  end

  test "delete answer -> save" do
    # delete answer
    delete_answer(@answer.id)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_delete_answer(@answer.content)
  end

  test "delete answer -> save -> undo -> save" do
    # delete answer
    delete_answer(@answer.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    # in this specific instance, a change in order is tolerable
    assert_equal @initial.sort, get_answers_content.sort
  end

  test "delete answer -> save -> undo -> save -> redo -> save" do
    # delete answer
    delete_answer(@answer.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_delete_answer(@answer.content)
  end

  test "change answer content -> undo -> redo" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # undo
    undo_action
    assert_answer_content(@answer.id, @initial_answer_content)
    # redo
    redo_action
    assert_answer_content(@answer.id, @modified_answer_content)
  end

  test "change answer content -> switch selection -> undo -> redo" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_answer_content(@answer.id, @initial_answer_content)
    # redo
    redo_action
    assert_answer_content(@answer.id, @modified_answer_content)
  end

  test "change answer content -> undo -> switch selection -> redo" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # undo
    undo_action
    assert_answer_content(@answer.id, @initial_answer_content)
    # switch selection
    select_question(@other.id)
    # redo
    redo_action
    assert_answer_content(@answer.id, @modified_answer_content)
  end

  test "change answer content -> save" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_answer_content(@answer.id, @modified_answer_content)
  end

  test "change answer content -> save -> undo -> save" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_answer_content(@answer.id, @initial_answer_content)
  end

  test "change answer content -> save -> undo -> save -> redo -> save" do
    # change content
    change_answer_content(@answer.id, @modify_content)
    assert_answer_content(@answer.id, @modified_answer_content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_answer_content(@answer.id, @modified_answer_content)
  end
end