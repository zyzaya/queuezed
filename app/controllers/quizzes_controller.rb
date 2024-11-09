class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes.order(:created_at)
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
    # extract question/answer/tag with meta: 'new'
    # update seperately
    # new q, q_id:
    # questions: [
    #   id: 
    #   prev_id: 
    #   answers: 
    # ]

    quiz = current_user.quizzes.find_by(id: params[:id])
    if (quiz.nil?)
      head :not_found
    elsif !params[:quiz.nil?]
      quiz_params = quiz_update_params
      if !quiz_params.permitted?
        head :bad_request
      else
        new_records = extract_new_records(quiz_params)
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
          quiz.transaction do
            id_conversions = create_new_records(quiz, new_records)
            convert_new_tag_ids(quiz_params, id_conversions)
            quiz.update!(quiz_params)
            quiz = current_user.quizzes.includes(questions: [:answers, :tags]).find_by(id: params[:id])
            result = inject_id_conversion(quiz, id_conversions)
            render(json: result)
          end
        rescue ActiveRecord::StatementInvalid
          head :internal_server_error
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

  def extract_new_records(params)
    result = {}
    return result if params["questions"].nil? 

    params["questions"].each do |q|
      if (q["meta"].eql?('new'))
        result["questions"] = [] if result["questions"].nil?
        result["questions"] << q
        params["questions"].delete(q)
      else
        new_q = {}
        unless q["answers"].nil?
          q["answers"].each do |a|
            if (a["meta"].eql?('new'))
              new_q["id"] = q["id"]
              new_q["answers"] = [] if new_q["answers"].nil?
              new_q["answers"] << a
              q["answers"].delete(a)
            end
          end
        end
        unless q["tags"].nil?
          q["tags"].each do |t|
            if (t["meta"].eql?('new'))
              new_q["id"] = q["id"]
              new_q["tags"] = [] if new_q["tags"].nil?
              new_q["tags"] << t
              q["tags"].delete(t)
            end
          end
        end
        unless new_q.eql?({})
          result["questions"] = [] if result["questions"].nil?
          result["questions"] << new_q
        end
      end
    end
    return result
  end

  def create_new_records(quiz, params)
    ids = {
      questions: [],
      answers: [],
      tags: [],
    }
    return ids if params["questions"].nil?
    
    question_ids = params["questions"].map { |q| q["id"] }
    questions = quiz.questions.where(id: question_ids)
    params["questions"].each do |q|
      question = nil
      if q["meta"].eql?("new")
        question = quiz.questions.create(content: q["content"])
        ids[:questions] << { id: question.id, prev_id: q["id"]}
      else
        question = questions.find(q["id"])
      end
      unless q["answers"].nil?
        q["answers"].each do |a|
          answer = question.answers.create(content: a["content"])
          ids[:answers] << { question_id: question.id, id: answer.id, prev_id: a["id"] }
        end
      end
      unless q["tags"].nil?
        q["tags"].each do |t|
          tag = question.tags.create(content: t["content"])
          ids[:tags] << { question_id: question.id, id: tag.id, prev_id: t["id"] }
        end
      end
    end
    return ids
  end

  def convert_new_tag_ids(params, id_conversions)
    return if params[:questions_attributes].nil?

    id_conversions[:tags].each do |convert|
      params[:questions_attributes].each do |q|
        unless q[:tags_attributes].nil?
          q[:tags_attributes].each do |t|
            t[:id] = convert[:id] if t[:id].eql?(convert[:prev_id])
          end
        end
      end
    end
  end

  def inject_id_conversion(quiz, id_conversions)
    result = quiz.as_json(
      only: [:name],
      include: {
        questions: {
          include: {
            answers: {
              only: [:id, :content]
            },
            tags: {
              only: [:id, :content]
            }
          }
        }
      }
    )
    id_conversions[:questions].each do |q|
      question = result["questions"].find { |e| e["id"].eql?(q[:id]) }
      question["prev_id"] = q[:prev_id]
    end
    id_conversions[:answers].each do |a|
      question = result["questions"].find { |e| e["id"].eql?(a[:question_id]) }
      answer = question["answers"].find { |e| e["id"].eql?(a[:id]) }

      answer["prev_id"] = a[:prev_id]
    end
    id_conversions[:tags].each do |t|
      question = result["questions"].find { |e| e["id"].eql?(t[:question_id]) }
      tag = question["tags"].find { |e| e["id"].eql?(t[:id]) }
      tag["prev_id"] = t[:prev_id]
    end
    return result
  end
end
