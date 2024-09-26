require "application_system_test_case"
require "test_helper"

class QuestionTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    visit_edit_page
    @initial = get_questions_content
  end

  def add_question
    page.find("#new_question").click
  end

  def delete_question(id)
    select_question(id)
    page.find("#delete_question").click
  end

  def assert_add_question
    assert_equal @initial + [""], get_questions_content
  end

  def assert_delete_question(content)
    assert_equal (@initial - [content]).sort, get_questions_content.sort
  end

  def assert_no_change_to_questions
    assert_equal @initial.sort, get_questions_content.sort
  end

  test "add question -> undo -> redo" do
    # add question
    add_question
    assert_add_question
    # undo
    undo_action
    assert_no_change_to_questions
    # redo
    redo_action
    assert_add_question
  end

  test "add question -> switch selection -> undo -> redo" do
    # add question
    add_question
    assert_add_question
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_questions
    # redo
    redo_action
    assert_add_question
  end

  test "add question -> undo -> switch selection -> redo" do
    # add question
    add_question
    assert_add_question
    # undo
    undo_action
    assert_no_change_to_questions
    # switch selection
    select_question(@other.id)
    # redo
    redo_action
    assert_add_question
  end

  test "add question -> save" do
    # add question
    add_question
    assert_add_question
    # save
    save_action
    visit_edit_page
    assert_add_question
  end

  test "add question -> save -> undo -> save" do
    # add question
    add_question
    assert_add_question
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    assert_no_change_to_questions
  end

  test "add question -> save -> undo -> save -> redo -> save" do
    # add question
    add_question
    assert_add_question
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    assert_add_question
  end

  test ("delete question -> undo -> redo") do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@question.content)
    # undo
    undo_action
    assert_no_change_to_questions
    # redo
    redo_action
    assert_delete_question(@question.content)
  end

  test ("delete question -> switch selection -> undo -> redo") do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@question.content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_questions
    # redo
    redo_action
    assert_delete_question(@question.content)
  end

  test ("delete question -> undo -> switch selection -> redo") do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@question.content)
    # undo 
    undo_action
    assert_no_change_to_questions
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_delete_question(@question.content)
  end

  test ("delete question -> save") do
    # delete question
    delete_question(@question.id)
    assert_delete_question(@question.content)
    # save
    save_action
    visit_edit_page
    assert_delete_question(@question.content)
  end

  # add question -> undo -> redo
  # add question -> switch selection -> undo -> redo
  # add question -> und -> switch selection -> redo
  # add question -> save
  # add question -> save -> undo -> save
  # add question -> save -> undo -> redo -> save
  # delete question -> undo -> redo
  # delete question -> switch selection -> undo -> redo
  # delete question -> und -> switch selection -> redo
  # delete question -> save
  # delete question -> save -> undo -> save
  # delete question -> save -> undo -> redo -> save
  # change question content -> undo -> redo
  # change question content -> switch selection -> undo -> redo
  # change question content -> und -> switch selection -> redo
  # change question content -> save
  # change question content -> save -> undo -> save
  # change question content -> save -> undo -> redo -> save
end