class QuestionHistoriesController < ApplicationController
  before_action :authenticate_user!
  
  def new
    @practice_session = PracticeSession.find(params[:practice_id])
    @quiz = @practice_session.quiz
    @practice_session.update(current: @practice_session.current + 1)
    if @practice_session.current >= @practice_session.length
      question_ids = @practice_session.order.flatten.compact
      @correct = @practice_session.question_histories.where(correct: true).count
      @question_histories = @practice_session.question_histories.includes(:question, :answer_histories)
      @total = @question_histories.count
      render 'practice_sessions/feedback'
    else
      current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
      @questions = Question.includes(:answers).where(id: current_question_ids)
    end
  end

  def create
    @practice_session = PracticeSession.find(params[:practice_id])
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
        question_history = q.histories.new(practice_session_id: @practice_session.id)
        question_correct = true
        q.answers.each do |a|
          if given[q.id].keys.include?(a.id)
            expected = a.content
            variants = expected.split(" / ")
            given_answer = given[q.id][a.id]
            correct = variants.include?(given_answer)
            question_correct = false if !correct
            question_history.answer_histories.new(
              answer_id: a.id,
              expected: expected,
              given: given_answer,
              correct: correct
            )
          end
        end
        question_history.correct = question_correct
        q.times_taken += 1
        q.last_taken = Time.now
        if (question_correct)
          q.times_correct += 1
          q.current_streak += 1
          if (q.current_streak > q.longest_streak)
            q.longest_streak = q.current_streak
          end
        else
          q.current_streak = 0
        end
        # update difficult
        if ((q.times_taken >= 3 && q.current_streak < 3) || ((q.times_correct.to_f / q.times_taken.to_f) < 0.5))
          Tag.find_or_create_by(content: "Difficult").questions << q
        end
        q.save
      end
    end

    current_question_ids = @practice_session.order[@practice_session.current].filter { |e| !e.nil? }
    @question_histories = @practice_session.question_histories.where(question_id: current_question_ids)
  end
  private
end