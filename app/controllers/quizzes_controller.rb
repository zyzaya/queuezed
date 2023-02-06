class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes
  end

  def edit
    @quiz = Quiz.find(params[:id])
  end

  def practice
    @quiz = Quiz.find(params[:id])
    @questions = @quiz.questions.pluck(:id).shuffle
    @current = Question.find(@questions.first)
  end
  private
end
