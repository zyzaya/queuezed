class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    @practice_session = @quiz.practice_sessions.new(current: 0)
    ids = []
    @quiz.questions.shuffle.each.with_index do |question|
      if (question.relations.pluck(:id) & ids).empty?
        @practice_session.practice_questions << PracticeQuestion.new(question_id: question.id)
        ids << question.id
      end
    end
    @practice_session.length = ids.length
    @practice_session.save
    @current = @practice_session.practice_questions.first.question
  end

  def show
    @quiz = Quiz.find(params[:id])
  end
  private
end
