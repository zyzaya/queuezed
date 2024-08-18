class QuestionHistoriesController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @practice_session = PracticeSession.find_by(id: params[:practice_id], quiz_id: current_user.quizzes.ids)
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      @practice_session.update(current: @practice_session.current + 1)
      if @practice_session.current >= @practice_session.length
        @correct = @practice_session.question_histories.where(correct: true).count
        @question_histories = @practice_session.question_histories.includes(:question, :answer_histories)
        @total = @question_histories.count
        render 'practice_sessions/feedback'
      else
        current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
        @questions = Question.includes(:answers).where(id: current_question_ids)
      end
    end
  end

  def create
    @practice_session = PracticeSession.find_by(id: params[:practice_id], quiz_id: current_user.quizzes.ids)
    # given[q_id][a_id] = value
    # given = {
    #   q_id: {
    #     a_id: "given text1",
    #     a_id: "given text2"
    #   }
    # }
    if @practice_session.nil?
      head :not_found
    else
      @quiz = @practice_session.quiz
      # converts ids from string to integers
      given = params.to_unsafe_hash[:given].map do |k, v|
        {
          k.to_i => v.map do |x, y|
            { x.to_i => y}
          end.reduce(:merge)
        }
      end.reduce(:merge)

      q_ids = given.keys
      Question.transaction do
        @quiz.questions.find(q_ids).each do |q|
          given_answers = given[q.id].values
          q.submit_answer(@practice_session, given_answers)
        end
      end

      current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
      @question_histories = @practice_session.question_histories.where(question_id: current_question_ids)
    end
  end
  private
end