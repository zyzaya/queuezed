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
      text_filter = practice_params[:text_filter]
      tag_filter = practice_params[:tag_filter]
      tag_filter = tag_filter.split(",").map { |t| t.to_i }
      review_filter = practice_params[:review_filter]
      practice = @quiz.new_practice(
        text_filter: text_filter,
        tag_filter: tag_filter,
        review: review_filter
      )
      if practice.nil?
        flash[:alert] = "Failed to create practice, no valid questions"
        redirect_to new_quiz_practice_path(@quiz.id)
      else
        practice.save
        @practice_session = practice
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
    params.permit(:authenticity_token, :commit, :quiz_id, :text_filter, :tag_filter, :review_filter)
  end
end
