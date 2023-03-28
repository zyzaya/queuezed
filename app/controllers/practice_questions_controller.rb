class PracticeQuestionsController < ApplicationController
  def show
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.find(params[:practice_session_id])
    @current = @practice_session.practice_questions.find(params[:practice_question_id]).question
  end
  private
end