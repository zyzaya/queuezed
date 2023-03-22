class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.find(params[:practice_session_id])
    if @practice_session.practice_questions.count == 1
      render 'practice_sessions/feedback'
    else
      @current = @practice_session.practice_questions.second.question
      @practice_session.practice_questions.first.destroy
    end
  end

  def create
    @quiz = Quiz.find(params[:id])
    @practice_session = PracticeSession.find(params[:practice_session_id])
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.first.question
  end
  private
end