class QuestionsController < ApplicationController
  def edit
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.find(params[:question_id])
    
    # render json: @question
  end
  private
end