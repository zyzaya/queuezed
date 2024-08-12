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
    # only allow valid params: permit
    # require necessary params: each+require
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
      params.permit! #permit
      # require
      # convert
      unless params[:quiz][:questions].nil?
        params[:quiz].transform_keys! do |k|
          k.eql?("questions") ? :questions_attributes : k
        end

        convert_meta(params[:quiz], :questions_attributes)
        params[:quiz][:questions_attributes].each do |question_params|
          question_params.transform_keys! do |k|
            case k
            when "answers" then :answers_attributes
            when "tags" then :tags_attributes
            else k end
          end
          convert_meta(question_params, :answers_attributes)
          convert_meta(question_params, :tags_attributes)
        end      
      end
      begin 
        quiz.update(params[:quiz])
        render(
          json: quiz,
          only: [:name],
          include: {
            questions: {
              include: {
                tags: {
                  only: [:id, :content]
                }
              }
            }
          }
        )
      rescue ActiveRecord::RecordNotFound => e
        head :not_found
      end
    end 
  end

  private
  def convert_meta(params, key)
    unless params[key].nil?
      params[key].each do |v|
        if v[:meta].eql?("delete") || v[:meta].eql?("remove")
          v[:_destroy] = 1
        elsif v[:meta].eql?("new")
          v.extract!(:id)
        end
        v.extract!(:meta)
      end
    end
  end
end
