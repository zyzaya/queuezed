class QuestionsController < ApplicationController
  def index
    @quiz = current_or_guest_user.quizzes.find_by(id: params[:quiz_id])
    if @quiz.nil?
      head :not_found
    else
      @questions = @quiz.questions.includes(:tags, :answers, :relations).order(:created_at)
      render(
        json: @questions, 
        only: [
          :id,
          :content,
          :last_taken,
          :next_review,
          :current_streak,
          :longest_streak,
          :times_correct,
          :times_taken,
          :rank,
          :difficult,
          :review,
          :mastered
        ],
        include: [
          tags: { only: [:id, :content] }, 
          answers: { only: [:id, :content] }, 
          relations: { only: :id }
        ]
      )
    end
  end
  
  def edit
    @question = Question.find_by(id: params[:id], quiz_id: current_or_guest_user.quizzes.ids)
    if (@question.nil?)
      head :not_found
    else
      @quiz = @question.quiz
    end
  end

  def new
    @quiz = current_or_guest_user.quizzes.find_by(id: params[:quiz_id])
    if (@quiz.nil?)
      head :not_found
    else
      @question = @quiz.questions.new
      render json: @question
    end
  end

  def destroy
    @question = Question.find_by(id: params[:id], quiz_id: current_or_guest_user.quizzes.ids)
    if (@question.nil?)
      head :not_found
    else
      @question.soft_destroy(Time.now)
      render json: @question
    end
  end
  private
end