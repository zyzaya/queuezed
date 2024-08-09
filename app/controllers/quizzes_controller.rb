class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes
  end

  def create
    @quiz = current_user.quizzes.create(name: "New Quiz")
    render "quizzes/edit"
  end

  def edit
    @quiz = current_user.quizzes.find_by(id: params[:id])
    if (@quiz.nil?)
      head :not_found
    end
    @quiz = Quiz.find(params[:id])
  end

  def destroy
    quiz = current_user.quizzes.find_by(id: params[:id])
    if (quiz.nil?)
      head :not_found
    else
      quiz.destroy
      redirect_to(quizzes_path())
    end
  end

  def update
    # rails puts json into params automagically
    # format of a save changes is
    # quiz: {
    #  name: "",
    #  questions: [
    #   {
    #     id:,
    #     meta: new/delete,
    #     content: "",
    #     answers: [
    #       {
    #         id:,
    #         meta: new/delete,
    #         content: "",
    #       }
    #     ],
    #     tags: [
    #       {
    #         id:,
    #         meta: new/add/remove,
    #         content: "",
    #       }
    #     ],
    #   }
    #  ]
    # }

    # response is 
    # {
    #   answers: { tempId: newId }
    #   tags: { tempId: newId }
    # }
    quiz = current_user.quizzes.find_by(id: params[:id])
    if (quiz.nil?)
      head :not_found
    elsif (params[:quiz].nil?)
    else
      response = {
        answers: {},
        tags: {}
      }
      ##
      success = false
      quiz.transaction do 
        update_name(quiz, params)
        success = update_all_questions(quiz, params)
        raise ActiveRecord::Rollback if (success == :not_found)
      end

      if (success == :not_found)
        head :not_found
      else
        quiz.save
        puts response
        render json: response
      end
    end
  end

  private
  def update_name(quiz, params)
    unless params[:quiz][:name].nil?
      quiz.name = params[:quiz][:name]
    end
  end

  def update_all_questions(quiz, params)
    unless params[:quiz][:questions].nil?
      params[:quiz][:questions].each do |q|
        question = if q[:meta].eql?("new")
          quiz.questions.new
        else
          quiz.questions.find_by(id: q[:id])
        end
        return :not_found if question.nil?

        if (q[:meta].eql?("delete"))
          question.destroy
        else
          success = update_question(question, q)
          return :not_found if success == :not_found
          question.save
        end
      end
    end
  end

  def update_question(question, changes)
    update_question_content(question, changes)
    success = update_all_answers(question, changes)
    return :not_found if success == :not_found
    success = update_all_tags(question, changes)
    return :not_found if success == :not_found
  end

  def update_question_content(question, changes)
    unless changes[:content].nil?
      question.content = changes[:content]
    end
  end

  def update_all_answers(question, changes)
    unless changes[:answers].nil?
      changes[:answers].each do |a|
        answer = if a[:meta].eql?("new")
          question.answers.new
        else
          question.answers.find_by(id: a[:id])
        end
        return :not_found if answer.nil?

        if (a[:meta].eql?("delete"))
          answer.destroy
        else
          update_answer(answer, a)
          answer.save
        end
      end
    end
    return true
  end

  def update_answer(answer, changes)
    unless changes[:content].nil?
      answer.content = changes[:content]
    end
  end

  def update_all_tags(question, changes)
    unless changes[:tags].nil?
      changes[:tags].each do |t|
        tag = if t[:meta].eql?("new")
          question.tags.new
        else
          Tag.find_by(id: t[:id])
        end
        return :not_found if tag.nil?

        if t[:meta].eql?('add')
          question.tags << tag
        elsif t[:meta].eql?("remove")
          question.tags.delete(tag)
        end
        update_tag(tag, t)
      end
    end
    return true
  end

  def update_tag(tag, changes)
    unless changes[:content].nil?
      tag.content = changes[:content]
    end
  end
end
