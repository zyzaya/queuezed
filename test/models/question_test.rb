require "test_helper"
require "minitest/mock"

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

  test "can submit multiple of the same answer" do
    question = questions(:john_one)
    initial = question.times_correct
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    assert_equal initial + 1, Question.find(question.id).times_correct
  end

  test "submit_answer does not increment current_streak when incorrect" do
    question = questions(:john_one)
    initial = question.current_streak
    question.submit_answer(practice_sessions(:johns), ["incorrect"])
    assert_equal initial, Question.find(question.id).current_streak
  end

  test "current_streak gets reset on incorrect answer" do
    question = questions(:john_one)
    question.update(current_streak: 5)
    question.submit_answer(practice_sessions(:johns), ["incorrect"])
    assert_equal 0, Question.find(question.id).current_streak
  end

  test "longest_streak is updated when surpassed by current_streak" do
    question = questions(:john_one)
    initial = 5
    question.update(current_streak: initial, longest_streak: initial)
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    assert_equal initial + 1, Question.find(question.id).longest_streak
  end

  test "review flag is set when past next_review time" do
    question = questions(:john_one)
    now = DateTime.now
    question.update(review: false, next_review: now - 10.days)
    result = Question.find(question.id)
    assert result.review
  end
  
  test "rank increases when review is true and answer is correct" do
    question = questions(:john_one)
    now = DateTime.now
    question.update(next_review: now, rank: 1)
    initial = question.rank
    DateTime.stub :now, now do
      question.submit_answer(practice_sessions(:johns), correct_answers(question))
      result = Question.find(question.id)
      assert_equal initial + 1, result.rank
      expected_next_review = now + question.quiz.interval_duration(initial + 1)
      assert_in_delta expected_next_review.utc, result.next_review.utc, 1.seconds
    end
  end

  test "rank decreases when review is true and answer is incorrect" do
    question = questions(:john_one)
    now = DateTime.now
    question.update(next_review: now, rank: 3)
    initial = question.rank
    DateTime.stub :now, now do
      question.submit_answer(practice_sessions(:johns), ["incorrect"])
      result = Question.find(question.id)
      assert_equal initial - 1, result.rank
      expected_next_review = now + question.quiz.interval_duration(initial - 1)
      assert_in_delta expected_next_review.utc, result.next_review, 1.seconds
    end
  end

  test "rank does not change if review is false" do
    question = questions(:john_one)
    question.update(
      next_review: DateTime.now + 10.days, 
      review: false, 
      rank: 3
    )
    initial = question.rank
    next_review = question.next_review
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    result = Question.find(question.id)
    assert_equal initial, result.rank
    assert_equal next_review, result.next_review
  end

  test "creates question history" do
    question = questions(:john_one)
    initial_count = question.histories.count
    question.submit_answer(practice_sessions(:johns), correct_answers(question))
    result = Question.find(question.id)
    assert_equal initial_count + 1, result.histories.count
    assert result.histories.last.correct
  end

  test "creates answer histories" do
    question = questions(:john_one)
    practice_session = practice_sessions(:johns)
    question.submit_answer(practice_session, correct_answers(question))
    result = Question.find(question.id)
    history = QuestionHistory.find_by(
      question_id: question.id, 
      practice_session_id: practice_session.id
    )
    result.answers.each do |a|
      answer_history = history.answer_histories.find_by(answer_id: a.id)
      assert_not_nil answer_history
      assert answer_history.correct
    end
  end

  test "creates answer histories even if no answer is given" do
    question = questions(:john_one)
    practice_session = practice_sessions(:johns)
    question.submit_answer(practice_session, [])
    result = Question.find(question.id)
    history = QuestionHistory.find_by(
      question_id: question.id,
      practice_session_id: practice_session.id
    )
    result.answers.each do |a|
      answer_history = history.answer_histories.find_by(answer_id: a.id)
      assert_not_nil answer_history
      assert_not answer_history.correct
    end
  end

  test "difficult is set to true when incorrect" do
    question = questions(:john_one)
    question.submit_answer(practice_sessions(:johns), [])
    result = Question.find(question.id)
    assert result.difficult
  end

  test "difficult is unset with a streak at least 3 and correct at least 50% total" do
    question = questions(:john_one)
    question.submit_answer(practice_sessions(:johns), [])
    1.upto(3) do 
      question.submit_answer(practice_sessions(:johns), correct_answers(question))
    end
    result = Question.find(question.id)
    assert_not result.difficult
  end
end
