class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.find_by(index: 0).question
  end

  def create
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.order(:index).find_by(taken: false).question
    puts "ahcreate: #{params}"
    # post answer info to db:
    # for each given answer
    #  Create AnswerHistory
    #   answer_id
    #   practice_session_id
    #   given: [user input]/params[answer_id]
    # add practice session id to answer_history
    # remove correct from answer history
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