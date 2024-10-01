ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module EditQuestionAssertionHelper
  def assert_add_question(initial)
    assert_equal initial + [""], get_questions_content
  end

  def assert_delete_question(initial, content)
    assert_equal (initial - [content]).sort, get_questions_content.sort
  end

  def assert_no_change_to_questions(initial)
    assert_equal initial.sort, get_questions_content.sort
  end

  def assert_question_content(id, content)
    assert_equal content, get_single_question_content(id)
    assert_includes get_questions_content, content
  end
end

module EditAnswerAssertionHelper
  def assert_answer_content(id, content)
    textarea = answer_container(id).find("textarea")
    assert_equal content, textarea.value
  end

  def assert_add_answer(initial)
    assert_equal initial + [""], get_answers_content
  end

  def assert_delete_answer(initial, content)
    assert_equal initial - [content], get_answers_content
  end

  def assert_no_change_to_answers(initial)
    assert_equal initial, get_answers_content
  end
end

module EditTagAssertionHelper
  def assert_add_tag(initial, content)
    assert_equal (initial + [content]).sort, get_tags_content
  end

  def assert_remove_tag(initial, content)
    assert_equal (initial - [content]).sort, get_tags_content
  end

  def assert_create_tag(initial_options, initial_content, content)
    assert_add_tag(initial_content, content)
    expected = (initial_options + [content]).sort
    # add to add tag options
    assert_equal expected, get_add_tag_options
    # add to filter by tag options
    assert_equal expected, get_filter_tag_options
  end

  def assert_no_change_to_tags(initial_content, initial_options)
    result = get_tags_content
    assert_equal initial_content, result
    assert_equal initial_options, get_add_tag_options
    assert_equal initial_options, get_filter_tag_options
  end
end

module EditActionHelper
  def save_action
    page.find("#save").click
  end

  def undo_action
    page.find("#undo").click
  end

  def redo_action
    page.find("#redo").click
  end

  def visit_edit_page
    visit edit_quiz_path(@quiz)
    # there's a problem where if you select a question inhumanely quick
    # the events don't fire properly on stimulus controllers
    sleep(0.5)
  end

  def add_question
    page.find("#new_question").click
  end

  def delete_question(id)
    select_question(id)
    page.find("#delete_question").click
  end

  def change_question_content(id, modify)
    textarea = single_question_textarea(id)
    textarea.send_keys(modify)
  end

  def add_answer(q_id) 
    container = single_question_edit_container(q_id)
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

  def add_tag(content)
    select content, from: "add_tag"
  end

  def remove_tag(q_id, content)
    container = question_edit_container(q_id)
    button = container.find(".tag_list > a") { |e| e.text.eql?(content) }
    button.click
  end

  def create_tag(q_id, content)
    container = question_edit_container(q_id)
    input = container.find("#create_tag")
    input.send_keys(content)
    input.send_keys(:return)
  end
end

module EditGetHelper
  def get_questions_content
    body = page.find(".zg_body")
    body.find_all(".zg_row > .zg_td:first-child").map do |e|
      e.text
    end
  end

  def get_single_question_content(id)
    return single_question_textarea(id).value
  end

  def get_answers_content
    container = single_question_edit_container(@question.id)
    container.find_all(".answer_content").map do |e|
      e.value
    end
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
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include EditActionHelper
  include EditGetHelper
  include EditQuestionAssertionHelper
  include EditAnswerAssertionHelper
  include EditTagAssertionHelper
end
