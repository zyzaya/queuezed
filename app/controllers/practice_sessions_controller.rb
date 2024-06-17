class PracticeSessionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @quiz = Quiz.find(params[:quiz_id])
    ids = []
    order = []
    @quiz.questions.includes(:relations).shuffle.each.with_index do |question|
      unless ids.include?(question.id)
        q_ids = [question.id] + question.relations.pluck(:id)
        order << q_ids
        ids += q_ids
      end
    end
    max = order.max { |a, b| a.length <=> b.length }.length
    order.map { |e| e.fill(nil, e.length, max - e.length) }
    @practice_session = @quiz.practice_sessions.create(current: 0, length: order.length, order: order)
    current_question_ids = @practice_session.order[0].filter { |e| !e.nil? }
    @questions = Question.includes(:answers).where(id: current_question_ids)
  end

  def show
    @quiz = Quiz.find(params[:quiz_id])
  end
  private
end
