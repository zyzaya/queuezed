class PracticeSessionsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:id])
    session = @quiz.practice_session
    session.destroy unless session.nil?
    new_session = PracticeSession.new(current_index: 0)
    @quiz.questions.shuffle.each.with_index do |question, i|
      new_session.practice_questions << PracticeQuestion.new(question_id: question.id, index: i)
    end
    @quiz.practice_session = new_session
    @current = @quiz.practice_session.practice_questions.find_by(index: 0).question
  end
  private
end
