ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

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
end

module EditGetHelper
  def get_questions_content
    body = page.find(".zg_body")
    body.find_all(".zg_row > .zg_td:first-child").map do |e|
      e.text
    end
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
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include EditActionHelper
  include EditGetHelper
end
