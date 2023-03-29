class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = @quiz.practice_sessions.find(params[:session_id])
    @practice_session.current += 1
    @practice_session.save
    current_practice_question = @practice_session.practice_questions.order(:id).offset(@practice_session.current).first
    if current_practice_question.nil?
      render 'practice_sessions/feedback'
    else
      @current = current_practice_question.question
    end
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = PracticeSession.includes(:answer_histories, :practice_questions).find(params[:session_id])
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.order(:id).offset(@practice_session.current).first.question
  end
  private
end