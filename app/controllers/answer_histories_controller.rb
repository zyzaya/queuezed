class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.find_by(index: 0).question
  end

  def create
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.order(:index).find_by(taken: false).question
    params[:given].each do |i, g|
      @quiz.practice_session.answer_histories.create(answer_id: i, given: g)
    end
    @current.taken = true
    @current = @quiz.practice_session.practice_questions.find(@current.index + 1)
    puts @current
    # post answer info to db:
    # for each given answer
    #  Create AnswerHistory
    #   answer_id
    #   practice_session_id
    #   given: [user input]/params[answer_id]
    # cycle current
    # if contains incorrect render immediate_feedback
    # if all correct render next question
    respond_to do |format|
      format.turbo_stream { }
      format.html { }
    end
  end
  private
end