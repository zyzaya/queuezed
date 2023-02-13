class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.find_by(index: 0).question
  end

  def create
    respond_to do |format|
      format.turbo_stream { }
      format.html { }
    end
  end
  private
end