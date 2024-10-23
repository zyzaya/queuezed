module EditActionHelper
  def select_question(id)
    content = Question.find(id).content
    row = page.find(".zg_row > .zg_td:first-child") { |e| e.text.eql?(content)}
    row.click
  end
  
  def save_action
    page.find("#save").click
  end

  def undo_action
    page.find("#undo").click
  end

  def redo_action
    page.find("#redo").click
  end

  def visit_edit_page(quiz)
    visit edit_quiz_path(quiz)
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

  def filter_by_text(text)
    page.find("#limit_add_related").check()
    input = page.find("#edit_filter")
    input.send_keys(text)
  end
end