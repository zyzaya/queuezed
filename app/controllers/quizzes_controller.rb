class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes
  end

  def edit
    @quiz = Quiz.find(params[:id])
  end

  def update
    render plain: ""
  end

  private
end
