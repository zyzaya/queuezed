class AnswerHistoriesController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @current = @quiz.practice_session.practice_questions.find_by(index: 0).question
  end

  def create
    @quiz = Quiz.find(params[:id])
    @practice_session = PracticeSession.find(params[:practice_session_id])
    # post answer info to db
    params[:given].each do |i, g|
      @practice_session.answer_histories.new(answer_id: i, given: g)
    end
    @practice_session.save
    # immediate_feedback
    # cycle current
    @practice_session.practice_questions.first.destroy
    @current = @practice_session.practice_questions.first.question
    puts @current
    respond_to do |format|
      format.turbo_stream { }
      format.html { }
    end
  end
  private
end