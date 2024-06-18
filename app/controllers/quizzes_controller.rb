class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes
  end

  def new
    @quiz = current_user.quizzes.create(name: "New Quiz")
    @quiz.srs_boxes.create(rank: 1)
    render "quizzes/edit"
  end

  def edit
    @quiz = Quiz.find(params[:id])
  end

  def destroy
    quiz = Quiz.find(params[:id])
    quiz.destroy
    redirect_to(quizzes_path())
  end

  def update
    # rails puts json into params automagically
    # format of a save changes is
    # quiz {
    #  quiz_title?: ""
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
    response = {
      answers: {},
      tags: {}
    }

    unless params[:quiz_title].nil?
      Quiz.find(params[:id]).update(name: params[:quiz_title])
    end
    unless params[:questions].nil?
      params[:questions].each do |q|
        ## content
        question = Question.find(q[:id])
        question.update(content: q[:content]) unless q[:content].nil?
        ## answers
        unless q[:answers].nil?
          q[:answers].each do |a|
            ## 
            answer = nil
            if a[:meta].eql?('new')
              answer = question.answers.create
              response[:answers][a[:id]] = answer.id
            else
              answer = Answer.find(a[:id])
            end

            if a[:meta].eql?('delete')
              answer.destroy
            else
              # update content
              unless a[:content].nil?
                variants = a[:content].split(/\s*\/\s*/)
                answer.answer_variants.clear
                variants.each do |v|
                  answer.answer_variants.new(content: v)
                end
              end
            end
          end
        end
        ## tags
        unless q[:tags].nil?
          q[:tags].each do |t|
            # if new create new
            tag = nil
            if t[:meta].eql?('new')
              tag = question.tags.create(content: t[:content])
              response[:tags][t[:id]] = tag.id
            else
              tag = Tag.find(t[:id])
            end

            if t[:meta].eql?('delete')
              tag.destroy
            elsif t[:meta].eql?('add')
              question.tags << tag
            elsif t[:meta].eql?('remove')
              question.tags.destroy(tag)
            end
          end
        end
        question.save
      end
    end
    puts response
    render json: response
  end

  private
end
