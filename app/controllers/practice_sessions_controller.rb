class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.new
    @quiz.questions.shuffle.each.with_index do |question|
      @practice_session.practice_questions << PracticeQuestion.new(question_id: question.id)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.first.question
    # redirect_to "/quizzes/#{params[:id]}/answer_histories/new"
  end


  def answer
    # post answer info to db
    # cycle practice_session current
    # @quiz.practice_sesson.practice_questions.order(:index).find_by(taken: false)
    puts params
    render 'practice_sessions/immediate_feedback'
  end

  def show
    @quiz = Quiz.find(params[:id])

  end
  private
end
