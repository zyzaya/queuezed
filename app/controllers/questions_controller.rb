class QuestionsController < ApplicationController
  def edit
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.find(params[:question_id])
    
    # render json: @question
  end

  def new
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.create

    render 'questions/edit'
  end
  private
end