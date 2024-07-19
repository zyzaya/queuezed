class QuestionHistoriesController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @practice_session = PracticeSession.find(params[:practice_id])
    @quiz = @practice_session.quiz
    @practice_session.update(current: @practice_session.current + 1)
    if @practice_session.current >= @practice_session.length
      question_ids = @practice_session.order.flatten.compact
      @correct = @practice_session.questions.where(correct: true).count
      @questions = @practice_session.questions
      @total = @questions.count
      render 'practice_sessions/feedback'
    else
      current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
      @questions = Question.includes(:answers).where(id: current_question_ids)
    end
  end

  def create
    @practice_session = PracticeSession.find(params[:practice_id])
    @quiz = @practice_session.quiz
    params[:given].each do |q_id, answers|
      question = Question.find(q_id)
      question_history = question.histories.new(practice_session_id: @practice_session.id)
      question_correct = true
      answers.each do |a_id, given|
        answer = Answer.find(a_id)
        expected = answer.content
        variants = expected.split(" / ")
        correct = variants.include?(given)
        question_correct = false if !correct
        question_history.answer_histories.new(
          answer_id: a_id,
          expected: expected,
          given: given,
          correct: correct,
        )
      end
      question_history.correct = question_correct
      question.times_taken += 1
      question.last_taken = Time.now
      if (question_correct)
        question.times_correct += 1
        question.current_streak += 1
        if (question.current_streak > question.longest_streak)
          question.longest_streak = question.current_streak
        end
      else
        question.current_streak = 0
      end
      question.save
    end

    current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
    @questions = Question.includes(answers: :histories).where(id: current_question_ids)
  end
  private
end