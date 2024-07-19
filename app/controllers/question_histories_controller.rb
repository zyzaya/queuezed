class AnswerHistoriesController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @practice_session = PracticeSession.find(params[:practice_id])
    @quiz = @practice_session.quiz
    @practice_session.update(current: @practice_session.current + 1)
    if @practice_session.current >= @practice_session.length
      question_ids = @practice_session.order.flatten.compact
    else
    
    end
  end

  def create
    
  end
  private
end