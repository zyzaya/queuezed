class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.new
    @quiz.questions.shuffle.each.with_index do |question|
      @practice_session.practice_questions << PracticeQuestion.new(question_id: question.id)
    end
    @practice_session.save
    @current = @practice_session.practice_questions.first.question
  end

  def show
    @quiz = Quiz.find(params[:id])
  end
  private
end
