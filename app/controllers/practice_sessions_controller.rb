class PracticeSessionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @quiz = current_user.quizzes.find_by(id: params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      @unfinished = @quiz.practice_sessions.where("current < length")
    end
  end

  def create
    @quiz = current_user.quizzes.find_by(id: params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      puts params
      ids = []
      order = []
      text_filter = params[:text_filter].downcase
      tag_filter = params[:tag_filter].split(",").map { |t| t.to_i }
      review_filter = params[:review_filter].eql?("true")
      questions = if review_filter
        @quiz.questions.where(review: review_filter)
      else
        @quiz.questions
      end
      # all questions that 
      #   have at least one answer
      #   content contains text_filter
      #   have all tags in tag_filter
      # related questions grouped together
      questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |question|
        if (!ids.include?(question.id) && # not already selected
          (!question.answers.empty?) && # has at least one answer
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
  end

  def show
    @practice_session = PracticeSession.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      @question_histories = @practice_session.question_histories
    end
  end
  private
end
