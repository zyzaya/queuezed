require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def select_question(id)
    content = Question.find(id).content
    row = page.find(".zg_row > .zg_td:first-child") { |e| e.text.eql?(content)}
    row.click
  end
end
