class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.find(params[:practice_session_id])
    @current = @practice_session.practice_questions.second.question
    respond_to do |format|
      format.turbo_stream { }
      format.html { }
    end
  end

  def create
    @quiz = Quiz.find(params[:id])
    @practice_session = PracticeSession.find(params[:practice_session_id])
    # post answer info to db
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.first.question
    # immediate_feedback
    # for q and each related q
    # q text
    #  given answer | correct answer variants
    # cycle current
    # @practice_session.practice_questions.first.destroy # this also needs to remove question relations
    # @current = @practice_session.practice_questions.first.question
    # puts @current
  end
  private
end