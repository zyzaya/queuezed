require "test_helper"
require "system/support/edit/EditActionHelper"
require "system/support/edit/EditAnswerAssertionHelper"
require "system/support/edit/EditGetHelper"
require "system/support/edit/EditQuestionAssertionHelper"
require "system/support/edit/EditTagAssertionHelper"
require "system/support/edit/EditRelationAssertionHelper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  include EditActionHelper
  include EditGetHelper
  include EditQuestionAssertionHelper
  include EditAnswerAssertionHelper
  include EditRelationAssertionHelper
  include EditTagAssertionHelper
end
