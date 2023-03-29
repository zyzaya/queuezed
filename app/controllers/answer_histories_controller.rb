class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = @quiz.practice_sessions.find(params[:session_id])
    @practice_session.current += 1
    @practice_session.save
    if @practice_session.current > @practice_session.length - 1
      render 'practice_sessions/feedback'
    else
      current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
      @questions = Question.includes(:answers).where(id: current_question_ids)
    end
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = PracticeSession.find(params[:session_id])
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    
    current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
    @questions = Question.includes(answers: [:answer_histories, :answer_variants]).where(id: current_question_ids)
  end
  private
end