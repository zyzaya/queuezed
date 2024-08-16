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
    quiz = current_user.quizzes.find_by(id: params[:id])
    if (quiz.nil?)
      head :not_found
    elsif !params[:quiz.nil?]
      quiz_params = quiz_update_params
      if !quiz_params.permitted?
        head :bad_request
      else
        unless quiz_params[:questions].nil?
          quiz_params.transform_keys! do |k|
            k.eql?("questions") ? :questions_attributes : k
          end
  
          convert_meta(quiz_params, :questions_attributes)
          quiz_params[:questions_attributes].each do |question_params|
            question_params.transform_keys! do |k|
              case k
              when "answers" then :answers_attributes
              when "tags" then :tags_attributes
              when "relations" then :relations_attributes
              else k end
            end
            convert_meta(question_params, :answers_attributes)
            convert_meta(question_params, :tags_attributes)
            convert_meta(question_params, :relations_attributes)
          end      
        end
        begin 
          quiz.update(quiz_params)
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
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end 
  end

  private
  def quiz_update_params
    params[:quiz].permit(
        :name,
        questions: [
          :id,
          :meta,
          :content,
          {
            answers: [
              :id,
              :meta,
              :content
            ]
          },
          {
            tags: [
              :id,
              :meta,
              :content
            ]
          },
          {
            relations: [
              :id,
              :meta
            ]
          }
        ]
      )
  end

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
