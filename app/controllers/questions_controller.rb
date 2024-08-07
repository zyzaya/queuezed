class QuestionsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @quiz = current_user.quizzes.find_by(id: params[:quiz_id])
    if @quiz.nil?
      head :not_found
    else
      @questions = @quiz.questions.includes(:tags).order(:id)
      render json: @questions, include: [:tags]
    end
  end
  
  def edit
    @question = Question.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if (@question.nil?)
      head :not_found
    else
      @quiz = @question.quiz
    end
  end

  def update
    @question = Question.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if (@question.nil?)
      head :not_found
    else
      @question.restore(@question.deleted_at)
      render json: @question  
    end
  end

  def new
    @quiz = current_user.quizzes.find_by(id: params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      @question = @quiz.questions.create
      render json: @question
    end
  end

  def destroy
    @question = Question.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if (@question.nil?)
      head :not_found
    else
      @question.soft_destroy(Time.now)
      render json: @question
    end
  end
  private
end