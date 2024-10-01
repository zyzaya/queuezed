require "application_system_test_case"
require "test_helper"

class TagTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
    @quiz = quizzes(:johns)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @has_tag = tags(:tag_1)
    @not_has_tag = tags(:tag_2)
    @new_tag_content = "new tag content"
    visit_edit_page
    select_question(@question.id)
    @initial = get_tags_content
    @initial_tag_options = quizzes(:johns).tags.sort.pluck(:content)
  end  



  test "add tag -> undo -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_add_tag(@initial, @not_has_tag.content)
  end

  test "add tag -> switch selection -> undo -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_add_tag(@initial, @not_has_tag.content)
  end

  test "add tag -> undo -> switch selection -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_add_tag(@initial, @not_has_tag.content)
  end

  test "add tag -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_tag(@initial, @not_has_tag.content)
  end

  test "add tag -> save -> undo -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags(@initial, @initial_tag_options)
  end

  test "add tag -> save -> undo -> save -> redo -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@initial, @not_has_tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_tag(@initial, @not_has_tag.content)
  end

  test "remove tag -> undo -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_remove_tag(@initial, @has_tag.content)
  end

  test "remove tag -> switch selection -> undo -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_remove_tag(@initial, @has_tag.content)
  end

  test "remove tag -> undo -> switch selection -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_remove_tag(@initial, @has_tag.content)
  end

  test "remove tag -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_remove_tag(@initial, @has_tag.content)
  end

  test "remove tag -> save -> undo -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags(@initial, @initial_tag_options)
  end

  test "remove tag -> save -> undo -> save -> redo -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@initial, @has_tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_remove_tag(@initial, @has_tag.content)
  end

  test "create tag -> undo -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
  end

  test "create tag -> switch selection -> undo -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # redo
    redo_action
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
  end

  test "create tag -> undo -> switch selection -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # undo
    undo_action
    assert_no_change_to_tags(@initial, @initial_tag_options)
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
  end

  test "create tag -> save" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
  end

  test "create tag -> save -> undo -> save" do
    #create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags(@initial, @initial_tag_options)
  end

  test "create tag -> save -> undo -> save -> redo -> save" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_create_tag(@initial_tag_options, @initial, @new_tag_content)
  end
end