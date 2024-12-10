module PracticeActions
  def start_practice
    click_button('Start')
  end

  def add_practice_tag_filter(content)
    select content, from: "add_tag_filter"
  end

  def add_practice_text_filter(text)
    input = page.find("#edit_filter")
    input.send_keys(text)
    input.send_keys(:return)
  end

  def submit_answers(correct)
    remaining = {}
    given = {}
    page.find_all("input.answer_input").each do |e|
      q_id = e["id"].match(/given\[(\d+)\]\[\]/)[1].to_i
      if remaining[q_id].nil?
        remaining[q_id] = Question.find(q_id).answers.pluck(:content)
        given[q_id] = []
      end
      answer = remaining[q_id].pop
      input = answer.split(" / ")[0]
      input += "WRONG" unless correct
      given[q_id] << {input: input, correct: answer}
      e.send_keys(input)
    end
    click_button('Next')
    return given
  end
end