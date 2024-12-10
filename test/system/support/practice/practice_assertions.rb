module PracticeAssertions
  def assert_question_feedback(given)
    given.each do |_, answers|
      answers.each do |v|
        if (v[:correct].split(" / ").include?(v[:input]))
          assert page.has_selector?(".question_feedback_container.correct input[value=\"#{v[:input]}\"]")
        else
          assert page.has_selector?(".question_feedback_container.incorrect input[value=\"#{v[:input]}\"]")
          assert page.has_selector?(".question_feedback_container.incorrect input[value=\"#{v[:correct]}\"]")
        end
      end
    end
  end
end