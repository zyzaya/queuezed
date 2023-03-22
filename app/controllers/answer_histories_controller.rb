class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.find(params[:practice_session_id])
    @practice_session.current += 1
    @practice_session.save
    current_practice_questions = @practice_session.practice_questions.order(:id).offset(@practice_session.current).first
    if @current.nil?
      render 'practice_sessions/feedback'
    else
      @current
    end
  end

  def create
    @quiz = Quiz.find(params[:id])
    @practice_session = PracticeSession.find(params[:practice_session_id])
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.order(:id).offset(@practice_session.current).first.question
  end
  private
end