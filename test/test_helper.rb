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
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include EditActionHelper
end
