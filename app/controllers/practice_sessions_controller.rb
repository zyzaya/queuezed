class PracticeSessionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @quiz = Quiz.find(params[:quiz_id])
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    ids = []
    order = []
    textFilter = params[:textFilter].downcase
    tagIds = params[:tagIds].split(" ").map { |t| t.to_i }
    # all questions that 
    #   have at least one answer
    #   content contains textFilter
    #   have a tag in tagIds
    # related questions grouped together

    @quiz.questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |question|
      if (!ids.include?(question.id) && # not already selected
        (question.answers.count > 0) && # has at least one answer
        (textFilter.eql?("") || question.content.downcase.include?(textFilter)) && 
        ((tagIds - question.tags.pluck(:id)).length == 0))
        # group related questions
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
