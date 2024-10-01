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

  def get_add_tag_options
    container = question_edit_container(@question.id)
    options = container.find_all("#add_tag > option") do |e|
      !["-1", "-2"].include?(e.value)
    end
    return options.map { |e| e.text }
  end

  def get_filter_tag_options
    options = page.find_all("#edit_add_tag_filter > option") do |e|
      !["-1", "-2", "review"].include?(e.value)
    end
    return options.map { |e| e.text }
  end

  def assert_add_tag(content)
    assert_equal (@initial + [content]).sort, get_tags_content
  end

  def assert_remove_tag(content)
    assert_equal (@initial - [content]).sort, get_tags_content
  end

  def assert_create_tag(content)
    assert_add_tag(content)
    expected = (@initial_tag_options + [content]).sort
    # add to add tag options
    assert_equal expected, get_add_tag_options
    # add to filter by tag options
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tags
    result = get_tags_content
    assert_equal @initial, result
    assert_equal @initial_tag_options, get_add_tag_options
    assert_equal @initial_tag_options, get_filter_tag_options
  end

  test "add tag -> undo -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_add_tag(@not_has_tag.content)
  end

  test "add tag -> switch selection -> undo -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_add_tag(@not_has_tag.content)
  end

  test "add tag -> undo -> switch selection -> redo" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_add_tag(@not_has_tag.content)
  end

  test "add tag -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_tag(@not_has_tag.content)
  end

  test "add tag -> save -> undo -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags
  end

  test "add tag -> save -> undo -> save -> redo -> save" do
    # add tag
    add_tag(@not_has_tag.content)
    assert_add_tag(@not_has_tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_add_tag(@not_has_tag.content)
  end

  test "remove tag -> undo -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_remove_tag(@has_tag.content)
  end

  test "remove tag -> switch selection -> undo -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # switch selection
    select_question(@other.id)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_remove_tag(@has_tag.content)
  end

  test "remove tag -> undo -> switch selection -> redo" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # undo
    undo_action
    assert_no_change_to_tags
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_remove_tag(@has_tag.content)
  end

  test "remove tag -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_remove_tag(@has_tag.content)
  end

  test "remove tag -> save -> undo -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags
  end

  test "remove tag -> save -> undo -> save -> redo -> save" do
    # remove tag
    remove_tag(@question.id, @has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_remove_tag(@has_tag.content)
  end

  test "create tag -> undo -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_create_tag(@new_tag_content)
  end

  test "create tag -> switch selection -> undo -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # switch selection -> undo
    select_question(@other.id)
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_create_tag(@new_tag_content)
  end

  test "create tag -> undo -> switch selection -> redo" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # undo
    undo_action
    assert_no_change_to_tags
    # switch selection -> redo
    select_question(@other.id)
    redo_action
    assert_create_tag(@new_tag_content)
  end

  test "create tag -> save" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # save
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_create_tag(@new_tag_content)
  end

  test "create tag -> save -> undo -> save" do
    #create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_no_change_to_tags
  end

  test "create tag -> save -> undo -> save -> redo -> save" do
    # create tag
    create_tag(@question.id, @new_tag_content)
    assert_create_tag(@new_tag_content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit_edit_page
    select_question(@question.id)
    assert_create_tag(@new_tag_content)
  end
end