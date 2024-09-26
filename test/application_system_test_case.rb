require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def select_question(id)
    content = Question.find(id).content
    row = page.find(".zg_row > .zg_td:first-child") { |e| e.text.eql?(content)}
    row.click
  end

  def question_edit_container(id)
    page.find(".question_detail[data-edit--question-id-value=\"#{id}\"]")
  end

  def single_question_edit_container(id)
    page.find(".single_question_edit[data-edit--single-question-id-value=\"#{id}\"]")
  end

  def single_question_textarea(id)
    page.find(".question_content[data-edit--single-question-id-value=\"#{id}\"]")
  end

  def answer_container(id)
    page.find(".answer_container[data-edit--answer-id-value=\"#{id}\"]")
  end
end
