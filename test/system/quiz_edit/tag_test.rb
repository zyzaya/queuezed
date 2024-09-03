require "application_system_test_case"

class TagTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do 
    sign_in users(:john)
  end

end