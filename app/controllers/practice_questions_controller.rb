class PracticeQuestionsController < ApplicationController
  def show
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = @quiz.practice_sessions.find(params[:session_id])
    @current = @practice_session.practice_questions.find(params[:question_id]).question
  end
  private
end