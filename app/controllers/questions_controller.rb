class QuestionsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @quiz = Quiz.find(params[:quiz_id])
    @questions = @quiz.questions.includes(:tags).order(:id)
    render json: @questions, include: [:tags]
  end
  
  def edit
    @question = Question.find(params[:id])
    @quiz = @question.quiz
  end

  def update
    @question = Question.find(params[:id])
    @question.restore(@question.deleted_at)
    render json: @question
  end

  def new
    @quiz = Quiz.find(params[:quiz_id])
    @quiz.srs_boxes.create(rank: 1) if @quiz.srs_boxes.empty?
    @question = @quiz.srs_boxes.first.questions.create
    render json: @question
  end

  def destroy
    @question = Question.find(params[:id])
    @question.soft_destroy(Time.now)
    render json: @question
  end
  private
end