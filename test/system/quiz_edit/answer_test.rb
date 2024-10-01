require "application_system_test_case"
require "test_helper"

class AnswerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @answer = answers(:john_one)
    @initial_answer_content = @answer.content
    @modify_content = "a"
    @modified_answer_content = @initial_answer_content + @modify_content
    visit_edit_page
    select_question(@question.id)
    @initial = get_answers_content(@question.id)
  end

  test "add answer -> undo -> redo" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # undo
    undo_action
    assert_no_change_to_answers(@question.id, @initial)
    # redo
    redo_action
    assert_add_answer(@question.id, @initial)
  end

  test "add answer -> switch selection -> undo -> redo" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_answers(@question.id, @initial)
    # redo
    redo_action
    assert_add_answer(@question.id, @initial)
  end

  test "add answer -> undo -> switch selection -> redo" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # undo
    undo_action
    assert_no_change_to_answers(@question.id, @initial)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_add_answer(@question.id, @initial)
  end

  test "add answer -> save" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_answer(@question.id, @initial)
  end

  test "add answer -> save -> undo -> save" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_answers(@question.id, @initial)
  end

  test "add answer -> save -> undo -> save -> redo -> save" do
    # add answer
    add_answer(@question.id)
    assert_add_answer(@question.id, @initial)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_answer(@question.id, @initial)
  end

  test "delete answer -> undo -> redo" do
    # delete answer
    delete_answer(@answer.id)
    assert_delete_answer(@question.id, @initial, @answer.content)
    # undo
    undo_action
    assert_no_change_to_answers(@question.id, @initial)
    # redo
    redo_action
    assert_delete_answer(@question.id, @initial, @answer.content)
  end

  test "delete answer -> switch selection -> undo -> redo" do
    # delete answer
    delete_answer(@answer.id)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_answers(@question.id, @initial)
    # redo
    redo_action
    assert_delete_answer(@question.id, @initial, @answer.content)
  end

  test "delete answer -> undo -> switch selection -> redo" do
    # delete answer -> undo -> switch selection
    delete_answer(@answer.id)
    undo_action
    # switch selection
    select_question(@other.id)
    # redo
    redo_action
    assert_delete_answer(@question.id, @initial, @answer.content)
  end

  test "delete answer -> save" do
    # delete answer
    delete_answer(@answer.id)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_delete_answer(@question.id, @initial, @answer.content)
  end

  test "delete answer -> save -> undo -> save" do
    # delete answer
    delete_answer(@answer.id)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    # in this specific instance, a change in order is tolerable
    assert_equal @initial.sort, get_answers_content(@question.id).sort
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
    visit_edit_page
    select_question(@question.id)
    assert_delete_answer(@question.id, @initial, @answer.content)
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
    visit_edit_page
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
    visit_edit_page
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
    visit_edit_page
    select_question(@question.id)
    assert_answer_content(@answer.id, @modified_answer_content)
  end
end