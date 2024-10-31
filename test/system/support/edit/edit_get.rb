module EditGet
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
  
  def get_questions_content
    body = page.find(".zg_body")
    body.find_all(".zg_row > .zg_td:first-child").map do |e|
      e.text
    end
  end

  def get_single_question_content(id)
    return single_question_textarea(id).value
  end

  def get_answers_content(q_id)
    container = single_question_edit_container(q_id)
    container.find_all(".answer_content").map do |e|
      e.value
    end
  end

  def get_tags_content(q_id)
    container = question_edit_container(q_id)
    container.find_all(".tag_list > a").map do |e|
      e.text
    end
  end

  def get_add_tag_options(q_id)
    container = question_edit_container(q_id)
    options = container.find_all("#add_tag > option") do |e|
      !["-1", "-2"].include?(e.value)
    end
    return options.map { |e| e.text }
  end

  def get_filter_tag_options
    options = page.find_all("#edit_add_tag_filter > option") do |e|
      !["-1", "-2", "review", "difficult"].include?(e.value)
    end
    return options.map { |e| e.text }
  end

  def get_add_relation_options
    options = page.find_all("#add_related > option") do |e|
      !["-1", "-2"].include?(e.value)
    end
    return options.map { |e| e.text }
  end

  def get_relations(q_id)
    count = 0
    related = page.find_all(".single_question_edit") do |e|
      e['data-edit--single-question-id-value'].to_s != q_id.to_s
    end
    
    return related.map { |e| e['data-edit--single-question-id-value']}
  end
end