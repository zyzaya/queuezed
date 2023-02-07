class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    # if not exist create
    # if exist delete
    # use all questions for now
    @questions = @quiz.questions.pluck(:id).shuffle
    @current = Question.find(@questions.first)
  end
  private
end
