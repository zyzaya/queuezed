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
    practice_params = practice_session_create_params(params)
    @quiz = current_user.quizzes.find_by(id: practice_params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      order = create_order(practice_params)
      if order.length <= 0
        flash[:alert] = "Practice has zero (0) questions"
        redirect_to new_quiz_practice_path
      else
        max = order.max { |a, b| a.length <=> b.length }.length
        order.map { |e| e.fill(nil, e.length, max - e.length) }
        @practice_session = @quiz.practice_sessions.create(
          current: 0, 
          length: order.length, 
          order: order,
          text_filter: practice_params[:text_filter],
          tag_filter: practice_params[:tag_filter]
        )
        current_question_ids = @practice_session.order[0].filter { |e| !e.nil? }
        @questions = Question.includes(:answers).where(id: current_question_ids)
        render 'practice_sessions/show'
      end
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
  def practice_session_create_params(params)
    params.require(:quiz_id)
    params.permit(:quiz_id, :text_filter, :tag_filter, :review_filter)
  end

  def create_order(params)
    questions = filter_review(params[:review_filter].eql?("true"))
    text_filter = params[:text_filter].downcase
    tag_filter = params[:tag_filter].split(",").map { |t| t.to_i }
    ids = []
    order = []
    questions.includes(:relations, :answers, :tags).shuffle.each.with_index do |q|
      if (!ids.include?(q.id) &&
        has_answers(q) &&
        has_text(q, text_filter) &&
        has_tags(q, tag_filter))
        # group related questions
        q_ids = [q.id] + q.relations.pluck(:id)
        order << q_ids
        ids += q_ids
      end
    end
    return order
  end

  def filter_review(review)
    if review
      @quiz.questions.where(review: true)
    else
      @quiz.questions
    end
  end

  def has_answers(question)
    !question.answers.empty?
  end

  def has_text(question, filter)
    filter.eql?("") || question.content.downcase.include?(filter)
  end

  def has_tags(question, filter)
    (filter - question.tags.pluck(:id)).length  == 0
  end
end
