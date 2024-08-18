require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  # sumbit_answer
  # statistics:
  #  time_taken
  #  times_correct
  #  current_streak
  #  longest_streak
  #  rank
  #  review
  # adds question history ((in)correct)
  # adds answer history
  def correct_answers(question)
    question.answers.pluck(:content).map do |c|
      c.split("/")[0].strip
    end
  end
  
  test "submit_answer updates times_taken" do
    question = questions(:john_one)
    initial = question.times_taken
    question.submit_answer(practice_sessions(:johns), [])
    assert_equal initial + 1, Question.find(question.id).times_taken
  end

  test "submit_answer updates times_corect when correct" do
    question = questions(:john_one)
    initial = question.times_correct
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    assert_equal initial + 1, Question.find(question.id).times_correct
  end

  test "submit_answer does not increment times_correct when not correct" do
    question = questions(:john_one)
    initial = question.times_correct
    question.submit_answer(practice_sessions(:johns), ["incorrect1"])
    assert_equal initial, Question.find(question.id).times_correct
  end

  test "submit_answer increments current_streak when correct" do
    question = questions(:john_one)
    initial = question.current_streak
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    assert_equal initial + 1, Question.find(question.id).current_streak
  end
end
