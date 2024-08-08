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
    # quiz {
    #  name?: ""
    #  questions: [
    #   {
    #    question_info: ""
    #    answers: []
    #    tags: []
    #   }
    #  ]
    # }
    # meta: delete, new, add, remove
    ## todo: save added answers, remove deleted answers,
    # save changes to content of answers/questions

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

      update_name(quiz, params)
      update_all_questions(quiz, params)
      # unless params[:quiz][:questions].nil?
      #   params[:quiz][:questions].each do |q|
      #     update_question(quiz, q)
      #     ## content
      #     question = Question.find(q[:id])
      #     question.update(content: q[:content]) unless q[:content].nil?
      #     ## answers
      #     unless q[:answers].nil?
      #       q[:answers].each do |a|
      #         ## 
      #         answer = nil
      #         if a[:meta].eql?('new')
      #           answer = question.answers.create
      #           response[:answers][a[:id]] = answer.id
      #         else
      #           answer = Answer.find(a[:id])
      #         end

      #         if a[:meta].eql?('delete')
      #           answer.destroy
      #         else
      #           # update content
      #           answer.update(content: a[:content]) unless a[:content].nil?
      #         end
      #       end
      #     end
      #     ## tags
      #     unless q[:tags].nil?
      #       q[:tags].each do |t|
      #         # if new create new
      #         tag = nil
      #         if t[:meta].eql?('new')
      #           tag = question.tags.create(content: t[:content])
      #           response[:tags][t[:id]] = tag.id
      #         else
      #           tag = Tag.find(t[:id])
      #         end

      #         if t[:meta].eql?('delete')
      #           tag.destroy
      #         elsif t[:meta].eql?('add')
      #           question.tags << tag
      #         elsif t[:meta].eql?('remove')
      #           question.tags.destroy(tag)
      #         end
      #       end
      #     end
      #     question.save
      #   end
      # end
      quiz.save
      puts response
      render json: response
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
          quiz.questions.find(q[:id])
        end

        if (q[:meta].eql?("delete"))
          question.destroy
        else
          update_question(question, q)
          question.save
        end
      end
    end
  end

  def update_question(question, changes)
    update_question_content(question, changes)
    update_all_answers(question, changes)
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
          question.answers.find(a[:id])
        end
        update_answer(answer, a)
        answer.save
      end
    end
  end

  def update_answer(answer, changes)
    unless changes[:content].nil?
      answer.content = changes[:content]
    end
  end
end
