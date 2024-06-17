class PracticeQuestionsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @quiz = Quiz.find(params[:quiz_id])
    @practice_session = @quiz.practice_sessions.find(params[:session_id])
    question_ids = @practice_session.order.find{ |e| e.include?(params[:question_id].to_i)}
    question_ids.filter! { |e| !e.nil? }
    @questions = Question.includes(answers: [:answer_histories, :answer_variants]).where(id: question_ids)
  end
  private
end