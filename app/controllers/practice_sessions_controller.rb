class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @questions = @quiz.questions.pluck(:id).shuffle
    @current = Question.find(@questions.first)
  end
  private
end
