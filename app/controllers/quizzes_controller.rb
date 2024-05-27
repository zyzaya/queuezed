class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes
  end

  def edit
    @quiz = Quiz.find(params[:id])
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

    unless params[:quiz_title].nil?
      Quiz.find(params[:quiz_id]).update(name: params[:quiz_title])
    end
    unless params[:questions].nil?
      params[:questions].each do |q|
        ## content
        question = Question.find(q[:id])
        question.update(content: q[:content]) unless q[:content].nil?
        ## answers
        unless q[:answers].nil?
          q[:answers].each do |a|
            answer = a[:meta].eql?('new') ? question.answers.new : Answer.find(a[:id])

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

              answer.save
            end
          end
        end
        ## tags
        unless q[:tags].nil?
          q[:tags].each do |t|
            # if new create new
            tag = t[:meta].eql?('new') ? question.tags.new(content: t[:content]) : Tag.find(t[:id])

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
    render plain: ""
  end


  private
end
