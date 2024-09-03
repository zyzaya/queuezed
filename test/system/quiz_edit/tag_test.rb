require "application_system_test_case"
require "test_helper"

class TagTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
    @question = questions(:john_one)
    @other = questions(:john_two)
    @has_tag = tags(:tag_1)
    @not_has_tag = tags(:tag_2)
    @new_tag_content = "new tag content"
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    @initial = get_tags_content
  end

  def add_tag(content)
    select content, from: "add_tag"
  end

  def remove_tag(content)
    container = question_edit_container(@question.id)
    button = container.find(".tag_list > a") { |e| e.text.eql?(content) }
    button.click
  end

  def create_tag(content)
    container = question_edit_container(@question.id)
    input = container.find("#create_tag")
    input.send_keys(content)
    input.send_keys(:return)
  end

  def get_tags_content
    container = question_edit_container(@question.id)
    container.find_all(".tag_list > a").map do |e|
      e.text
    end
  end

  def get_add_tag_options
    container = question_edit_container(@question.id)
    options = container.find_all("#add_tag > option") do |e|
      !["-1", "-2"].include?(e)
    end
    return options.map { |e| e.text }
  end

  def get_filter_tag_options
    options = page.find_all("#edit_add_tag_filter > option") do |e|
      !["-1", "-2"].include?(e)
    end
    return options.map { |e| e.text }
  end

  def assert_add_tag(content)
    result = get_tags_content
    assert_equal @initial.length + 1, result.length
    assert_equal [content], result - @initial
  end

  def assert_remove_tag(content)
    result = get_tags_content
    assert_equal @initial.length - 1, result.length
    assert_equal [content], @initial - result
  end

  def assert_create_tag(content)
    assert_add_tag(content)
    expected = @initial + [content]
    # add to add tag options
    assert_equal expected, get_add_tag_options
    # add to filter by tag options
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tags
    result = get_tags_content
    assert_equal result, initial
    assert_equal result, get_add_tag_options
    assert_equal result, get_filter_tag_options
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
    visit edit_quiz_path(quizzes(:johns))
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
    visit edit_quiz_path(quizzes(:johns))
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
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_add_tag(@not_has_tag.content)
  end

  test "remove tag -> undo -> redo" do
    # remove tag
    remove_tag(@has_tag.content)
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
    remove_tag(@has_tag.content)
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
    remove_tag(@has_tag.content)
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
    remove_tag(@has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_remove_tag(@has_tag.content)
  end

  test "remove tag -> save -> undo -> save" do
    # remove tag
    remove_tag(@has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save -> undo -> save
    save_action
    undo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_no_change_to_tags
  end

  test "remove tag -> save -> undo -> save -> redo -> save" do
    # remove tag
    remove_tag(@has_tag.content)
    assert_remove_tag(@has_tag.content)
    # save -> undo -> save -> redo -> save
    save_action
    undo_action
    save_action
    redo_action
    save_action
    visit edit_quiz_path(quizzes(:johns))
    select_question(@question.id)
    assert_remove_tag(@has_tag.content)
  end

  test "create tag -> undo -> redo" do
    # create tag
    create_tag(@new_tag_content)
    assert_create_tag(@new_tag_content)
    # undo
    undo_action
    assert_no_change_to_tags
    # redo
    redo_action
    assert_create_tag(@new_tag_content)
  end
  # add tag -> undo -> redo
  # add tag -> switch selection -> undo -> redo
  # add tag -> undo -> switch selection -> reo
  # add tag -> save
  # add tag -> save -> undo -> save
  # add tag -> save -> undo -> save -> redo -> save
  # remove tag -> undo -> redo
  # remove tag -> switch selection -> undo -> redo
  # remove tag -> undo -> switch selection -> reo
  # remove tag -> save
  # remove tag -> save -> undo -> save
  # remove tag -> save -> undo -> save -> redo -> save
  # create new tag -> undo -> redo
  # create new tag -> switch selection -> undo -> redo
  # create new tag -> undo -> switch selection -> reo
  # create new tag -> save
  # create new tag -> save -> undo -> save
  # create new tag -> save -> undo -> save -> redo -> save
end