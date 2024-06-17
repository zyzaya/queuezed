class AnswerHistoriesController < ApplicationController
  def new
    @practice_session = PracticeSession.find(params[:practice_id])
    @quiz = @practice_session.quiz
    @practice_session.current += 1
    @practice_session.save
    if @practice_session.current > @practice_session.length - 1
      question_ids = @practice_session.order.flatten.compact
      @correct = @practice_session.answer_histories.where(correct: true).count
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
    params[:given].each do |i, g|
      answer = Answer.find(i)
      variants = answer.answer_variants.pluck(:content)
      expected = variants.join(" / ")
      correct = variants.include?(g)
      @practice_session.answer_histories.new(answer_id: i, given: g, expected: expected, correct: correct)
    end
    @practice_session.save
    
    current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
    @questions = Question.includes(answers: [:answer_histories, :answer_variants]).where(id: current_question_ids)
  end
  private
end