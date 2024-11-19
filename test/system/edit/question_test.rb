require "application_system_test_case"
require "test_helper"
require "system/support/edit/edit_actions"
require "system/support/edit/edit_get"
require "system/support/edit/question_assertions"
require "system/support/edit/tag_assertions"

class QuestionTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include EditActions
  include EditGet
  include QuestionAssertions
  include TagAssertions

  setup do
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @tag = tags(:tag_1)
    @initial_tag_options = @quiz.tags.sort.pluck(:content)
    @initial_question_content = @question.content
    @modify_content = "a"
    @modified_question_content = @initial_question_content + @modify_content
    visit_edit_page(@quiz)
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
    visit_edit_page(@quiz)
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
    visit_edit_page(@quiz)
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
    visit_edit_page(@quiz)
    assert_add_question(@initial)
  end

  test "delete question -> undo -> redo" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # undo
    undo_action
    assert_no_change_to_questions(@initial)
    assert_no_change_to_tag_options(@question.id, @initial_tag_options)
    # redo
    redo_action
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
  end

  test "delete question -> switch selection -> undo -> redo" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_questions(@initial)
    assert_no_change_to_tag_options(@question.id, @initial_tag_options)
    # redo
    redo_action
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
  end

  test "delete question -> undo -> switch selection -> redo" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # undo 
    undo_action
    assert_no_change_to_questions(@initial)
    assert_no_change_to_tag_options(@question.id, @initial_tag_options)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
  end

  test "delete question -> save" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # save
    save_action
    visit_edit_page(@quiz)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
  end

  test "delete question -> save -> undo -> save" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@other.id)
    assert_no_change_to_questions(@initial)
    assert_no_change_to_tag_options(@other.id, @initial_tag_options)
  end

  test "delete question -> save -> undo -> save -> redo -> save" do
    # delete question
    delete_question(@question.id)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    sleep(5)
    undo_action
    save_action
    assert_no_change_to_questions(@initial)
    redo_action
    save_action
    visit_edit_page(@quiz)
    select_question(@other.id)
    assert_delete_question(@initial, @question.content)
    assert_remove_tag_option(@other.id, @initial_tag_options, @tag.content)
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
    visit_edit_page(@quiz)
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
    visit_edit_page(@quiz)
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
    visit_edit_page(@quiz)
    select_question(@question.id)
    assert_question_content(@question.id, @modified_question_content)
  end
  
  test "changing question content changes add relation options" do
    expected = @quiz.questions.where.not(id: [@question.id, @other.id]).pluck(:content)
    expected << (@question.content + @modify_content)
    expected.sort!
    select_question(@question.id)
    change_question_content(@question.id, @modify_content)
    select_question(@other.id)
    assert_equal expected, get_add_relation_options()
  end
end