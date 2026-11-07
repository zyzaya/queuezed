class QuestionHistoriesController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @practice_session = PracticeSession.find_by(id: params[:practice_id], quiz_id: current_or_guest_user.quizzes.ids)
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      if @practice_session.finished?
        redirect_to practice_path(@practice_session)
      else
        @questions = @practice_session.current_questions
      end
    end
  end

  def create
    @practice_session = PracticeSession.find_by(id: params[:practice_id], quiz_id: current_or_guest_user.quizzes.ids)
    # given[q_id][a_id] = value
    # given = {
    #   q_id: ["given1", "given2"]
    # }
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      given = params[:given]
      q_ids = given.keys.map { |id| id.to_i }
      current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
      @question_histories = @practice_session.question_histories.where(question_id: current_question_ids)
      Question.transaction do
        @quiz.questions.find(q_ids).each do |q|
          q.submit_answer(@practice_session, given[q.id.to_s])
        end
        @practice_session.next_question
      end
    end
  end
  private
end