class PracticeSessionsController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @quiz = current_user.quizzes.find_by(id: params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      @unfinished = @quiz.practice_sessions.order(:created_at).where("current < length")
    end
  end

  def create
    practice_params = practice_session_create_params(params)
    @quiz = current_user.quizzes.find_by(id: practice_params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      text_filter = practice_params[:text_filter]
      text_filter = '' if text_filter.nil?
      tag_filter = practice_params[:tag_filter]
      tag_filter = '' if tag_filter.nil?
      tag_filter = tag_filter.split(",").map { |t| t.to_i }
      review_filter = practice_params[:review_filter] == "true"
      difficult_filter = practice_params[:difficult_filter] == "true"
      limit = practice_params[:limit]
      limit = false if (!limit || limit.eql?("") || limit.to_i <= 0)
      practice = @quiz.new_practice(
        text_filter: text_filter,
        tag_filter: tag_filter,
        review: review_filter,
        difficult: difficult_filter,
        limit: limit,
      )
      if practice.nil?
        flash[:alert] = "Failed to create practice, no valid questions"
        redirect_to new_quiz_practice_path(@quiz.id)
      else
        practice.save
        redirect_to action: "show", id: practice.id
      end
    end
  end

  def show
    @practice_session = PracticeSession.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      @questions = @practice_session.current_questions
      if (@practice_session.finished?)
        @correct = @practice_session.question_histories.where(correct: true).count
        @question_histories = @practice_session.question_histories.includes(:question, :answer_histories)
        @total = @question_histories.count
        render 'practice_sessions/feedback'
      end
    end
  end

  def finish
    @practice_session = PracticeSession.find_by(id: params[:id], quiz_id: current_user.quizzes.ids)
    if (@practice_session.nil?)
      head :not_found
    else
      @practice_session.finish()
    end
    render partial: 'unfinished', locals: { session: @practice_session }
  end
  private
  def practice_session_create_params(params)
    params.require(:quiz_id)
    params.permit(:authenticity_token, :commit, :quiz_id, :text_filter, :tag_filter, :review_filter, :difficult_filter, :limit)
  end
end
