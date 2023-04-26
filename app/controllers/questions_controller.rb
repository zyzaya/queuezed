class QuestionsController < ApplicationController
  def edit
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.find(params[:question_id])
    
    # render json: @question
  end

  def new
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.srs_boxes.first.questions.create
    render json: @question
  end

  def delete
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.find(params[:question_id])
    @question.destroy
    render json: @question
  end
  private
end