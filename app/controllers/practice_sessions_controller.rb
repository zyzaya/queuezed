class PracticeSessionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @quiz = Quiz.find(params[:quiz_id])
    @unfinished = @quiz.practice_sessions.where("current < length")
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    ids = []
    order = []
    text_filter = params[:text_filter].downcase
    tag_filter = params[:tag_filter].split(",").map { |t| t.to_i }
    # all questions that 
    #   have at least one answer
    #   content contains text_filter
    #   have all tags in tag_filter
    # related questions grouped together

    @quiz.questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |question|
      if (!ids.include?(question.id) && # not already selected
        (question.answers.count > 0) && # has at least one answer
        (text_filter.eql?("") || question.content.downcase.include?(text_filter)) && 
        ((tag_filter - question.tags.pluck(:id)).length == 0))
        # group related questions
        q_ids = [question.id] + question.relations.pluck(:id)
        order << q_ids
        ids += q_ids
      end
    end

    max = order.max { |a, b| a.length <=> b.length }.length
    order.map { |e| e.fill(nil, e.length, max - e.length) }
    @practice_session = @quiz.practice_sessions.create(
      current: 0, 
      length: order.length, 
      order: order,
      text_filter: params[:text_filter],
      tag_filter: params[:tag_filter]
    )
    current_question_ids = @practice_session.order[0].filter { |e| !e.nil? }
    @questions = Question.includes(:answers).where(id: current_question_ids)
    render 'practice_sessions/show'
  end

  def show
    @practice_session = PracticeSession.find(params[:id])
    @quiz = @practice_session.quiz
    current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
    @questions = Question.includes(:answers).where(id: current_question_ids)
    
  end
  private
end
