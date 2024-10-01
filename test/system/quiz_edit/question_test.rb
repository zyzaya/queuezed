require "application_system_test_case"
require "test_helper"

class QuestionTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @initial_question_content = @question.content
    @modify_content = "a"
    @modified_question_content = @initial_question_content + @modify_content
    visit_edit_page
    @initial = get_questions_content
  end

  test "add question -> undo -> redo" do
    # add question
    add_question
    assert_add_question(@initial)
    # undo
    undo_action
    assert_no_change_to_questions(@initial)
    # redo
    redo_action
    assert_add_question(@initial)
  end

  test "add question -> switch selection -> undo -> redo" do
    # add question
    add_question
    assert_add_question(@initial)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_questions(@initial)
    # redo
    redo_action
    assert_add_question(@initial)
  end

  test "add question -> undo -> switch selection -> redo" do
    # add question
    add_question
    assert_add_question(@initial)
    # undo
    undo_action
    assert_no_change_to_questions(@initial)
    # switch selection
    select_question(@other.id)
    # redo
    redo_action
    assert_add_question(@initial)
  end

  test "add question -> save" do
    # add question
    add_question
    assert_add_question(@initial)
    # save
    save_action
    visit_edit_page
    assert_add_question(@initial)
  end

  test "add question -> save -> undo -> save" do
    # add question
    add_question
    assert_add_question(@initial)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    assert_no_change_to_questions(@initial)
  end

  test "add question -> save -> undo -> save -> redo -> save" do
    # add question
    add_question
    assert_add_question(@initial)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    assert_add_question(@initial)
  end

  test "delete question -> undo -> redo" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # assert_tag_list
    # assert tags?
    # undo
    undo_action
    assert_no_change_to_questions(@initial)
    # redo
    redo_action
    assert_delete_question(@initial, @question.content)
  end

  test "delete question -> switch selection -> undo -> redo" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_questions(@initial)
    # redo
    redo_action
    assert_delete_question(@initial, @question.content)
  end

  test "delete question -> undo -> switch selection -> redo" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # undo 
    undo_action
    assert_no_change_to_questions(@initial)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_delete_question(@initial, @question.content)
  end

  test "delete question -> save" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # save
    save_action
    visit_edit_page
    assert_delete_question(@initial, @question.content)
  end

  test "delete question -> save -> undo -> save" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    assert_no_change_to_questions(@initial)
  end

  test "delete question -> save -> undo -> save -> redo -> save" do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@initial, @question.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    assert_delete_question(@initial, @question.content)
  end

  test "change question content -> undo -> redo" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # undo
    undo_action
    assert_question_content(@question.id, @initial_question_content)
    # redo
    redo_action
    assert_question_content(@question.id, @modified_question_content)
  end

  test "change question content -> switch selection -> undo -> redo" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_question_content(@question.id, @initial_question_content)
    # redo
    redo_action
    assert_question_content(@question.id, @modified_question_content)
  end

  test "change question content -> undo -> switch selection -> redo" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # undo
    undo_action
    assert_question_content(@question.id, @initial_question_content)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_question_content(@question.id, @modified_question_content)
  end

  test "change question content -> save" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_question_content(@question.id, @modified_question_content)
  end

  test "change question content -> save -> undo -> save" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_question_content(@question.id, @initial_question_content)
  end

  test "change question content -> save -> undo -> save -> redo -> save" do
    select_question(@question.id)
    # change content
    change_question_content(@question.id, @modify_content)
    assert_question_content(@question.id, @modified_question_content)
    # save - undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_question_content(@question.id, @modified_question_content)
  end
end