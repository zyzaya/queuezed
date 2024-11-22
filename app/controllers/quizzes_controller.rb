class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes.includes(:questions).order(:created_at)
    @difficult_counts = Question.where(quiz_id: @quizzes, difficult: true).group(:quiz_id).count
    @review_counts = Question.where(quiz_id: @quizzes, review: true).group(:quiz_id).count
  end

  def create
    @quiz = current_user.quizzes.create(name: "New Quiz")
    render "quizzes/edit"
  end

  def edit
    @quiz = current_user.quizzes.find_by(id: params[:id])
    if (@quiz.nil?)
      head :not_found
    else
      @difficult_count = @quiz.questions.where(difficult: true).count
      @review_count = @quiz.questions.where(review: true).count
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
    quiz = current_user.quizzes.includes(:questions).find_by(id: params[:id])
    if (quiz.nil?)
      head :not_found
    elsif !params[:quiz.nil?]
      quiz_params = quiz_update_params
      if !quiz_params.permitted?
        head :bad_request
      else
        # create new records from params
        # remove parameters with meta = 'new' from params
        # update ids of remaining parameters with ids of new records
        # update quiz
        # inject old ids into result

        begin
          quiz.transaction do
            # id_conversions = create_new_records(quiz, quiz_params)
            # remove_new(quiz_params)
            # convert_to_new_ids(quiz_params, id_conversions)
            # convert_to_attributes(quiz_params)
            # quiz.update!(quiz_params)
            # quiz = current_user.quizzes.includes(questions: [:answers, :tags]).find_by(id: params[:id])
            # result = inject_id_conversion(quiz, id_conversions)
            # render(json: result)
            ids = {
              questions: [],
              answers: [],
              tags: [],
            }
            quiz.name = quiz_params["name"] unless quiz_params["name"].nil?
            puts quiz_params
            quiz_params["questions"]&.each do |q|
              question = Question.find_by(quiz_id: quiz.id, id: q["id"])
              raise ActiveRecord::RecordNotFound if question.nil? && !q["meta"].eql?("new")
              if q["meta"].eql?("new")
                if (question.nil?)
                  question = quiz.questions.create(content: q["content"])
                  ids[:questions] << {id: question.id, prev_id: q["id"] }
                else
                  question.restore
                end
              elsif q["meta"].eql?("delete")
                question&.soft_destroy
              end
              question.content = q["content"] unless q["content"].nil?
              # answers
              q["answers"]&.each do |a|
                answer = Answer.find_by(question_id: question.id, id: a["id"])
                raise ActiveRecord::RecordNotFound if answer.nil? && !a["meta"].eql?("new")
                if a["meta"].eql?("new")
                  if (answer.nil?)
                    answer = question.answers.create
                    ids[:answers] << {question_id: question.id, id: answer.id, prev_id: a["id"]}
                  else
                    answer.restore
                  end
                elsif a["meta"].eql?("delete")
                  answer&.soft_destroy
                end
                answer.content = a["content"] unless a["content"].nil?
              end
              # tags
              q["tags"]&.each do |t|
                t_id = ids[:tags].find { |e| e[:prev_id].eql?(t["id"]) }
                t_id = t_id.nil? ? t["id"] : t_id[:id]
                tag = Tag.find_by(id: t_id)
                raise ActiveRecord::RecordNotFound.new if tag.nil? && !t["meta"].eql?("new")
                if t["meta"].eql?("new")
                  if tag.nil?
                    tag = question.tags.create(content: t["content"])
                    ids[:tags] << { question_id: question.id, id: tag.id, prev_id: t["id"] }
                  else
                    question.tags << tag
                  end
                elsif t["meta"].eql?("delete") || t["meta"].eql?("remove")
                  question.tags.delete(tag) unless tag.nil?
                end
              end
              # meta: new, delete
            end
            # relations
            quiz_params["questions"]&.each do |q|
              q_id = ids[:questions].find { |e| e[:prev_id].eql?(q["id"]) }
              q_id = q_id.nil? ? q["id"] : q_id[:id]
              question = Question.find_by(quiz_id: quiz.id, id: q_id)
              q["relations"]&.each do |r|
                r_id = ids[:questions].find { |e| e[:prev_id].eql?(r["id"]) }
                r_id = r_id.nil? ? r["id"] : r_id[:id]
                relation = Question.find_by(quiz_id: quiz.id, id: r_id)
                if r["meta"].eql?("new") || r["meta"].eql?("add")
                  question.relations << relation unless relation.nil?
                elsif r["meta"].eql?("delete") || r["meta"].eql?("remove")
                  question.relations.delete(relation) unless relation.nil?
                end
              end
            end

            puts ids
            quiz.save
            result = inject_id_conversion(quiz, ids)
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

  def convert_to_attributes(quiz_params)
    unless quiz_params[:questions].nil?
      quiz_params.transform_keys! do |k|
        k.eql?("questions") ? :questions_attributes : k
      end

      convert_meta(quiz_params, :questions_attributes, true)
      quiz_params[:questions_attributes].each do |question_params|
        question_params.transform_keys! do |k|
          case k
          when "answers" then :answers_attributes
          when "tags" then :tags_attributes
          when "relations" then :relations_attributes
          else k end
        end
        convert_meta(question_params, :answers_attributes, true)
        convert_meta(question_params, :tags_attributes, false)
        convert_meta(question_params, :relations_attributes, false)
      end      
    end
  end

  def convert_meta(params, key, soft_destroy)
    unless params[key].nil?
      params[key].each do |v|
        if v[:meta].eql?("delete") || v[:meta].eql?("remove")
          if soft_destroy
            v[:_soft_destroy] = 1
          else
            v[:_destroy] = 1
          end
        elsif v[:meta].eql?("new")
          v.extract!(:id)
        end
        v.extract!(:meta)
      end
    end
  end

  def create_new_records(quiz, params)
    ids = {
      questions: [],
      answers: [],
      tags: [],
    }
    return ids if params["questions"].nil?
    
    params["questions"].each do |q|
      question = Question.find_or_create_by(quiz_id: quiz.id, id: q["id"]) do |obj|
        obj.content = q["content"]
      end
      if (q["id"] == question.id && q["meta"].eql?("new"))
        question.restore  
      else
        if (q["id"] != question.id)
          ids[:questions] << { id: question.id, prev_id: q["id"]}
          question.content = q["content"]
        end
        unless q["answers"].nil?
          q["answers"].each do |a|
            if (a["meta"].eql?("new"))
              answer = question.answers.create(content: a["content"])
              ids[:answers] << { question_id: question.id, id: answer.id, prev_id: a["id"] }
            end
          end
        end
        unless q["tags"].nil?
          q["tags"].each do |t|
            if t["meta"].eql?("new")
              tag = question.tags.create(content: t["content"])
              ids[:tags] << { question_id: question.id, id: tag.id, prev_id: t["id"] }
            end
          end
        end
      end
    end
    return ids
  end

  def remove_new(params)
    return if params["questions"].nil?

    params["questions"].delete_if do |q|
      unless q["answers"].nil?
        q["answers"].delete_if { |a| a["meta"].eql?("new") }
      end
      unless q["tags"].nil?
        q["tags"].delete_if { |t| t["meta"].eql?("new") }
      end

      q["meta"].eql?("new") &&
        (q["answers"].nil? || q["answers"].empty?) &&
        (q["tags"].nil? || q["tags"].empty?) &&
        (q["relations"].nil? || q["relations"].empty?)
    end
  end

  def convert_to_new_ids(params, id_conversions)
    return if params["questions"].nil?

    params["questions"].each do |q|
      q_id = id_conversions[:questions].find { |e| q["id"].eql?(e[:prev_id]) }
      q.extract!("meta") if q["meta"].eql?("new")
      q["id"] = q_id[:id] unless q_id.nil?

      unless q["answers"].nil?
        q["answers"].each do |a|
          a_id = id_conversions[:answers].find { |e| a["id"].eql?(e[:prev_id]) }
          a.extract!("meta") if a["meta"].eql?("new")
          a["id"] = a_id[:id] unless a_id.nil?
        end
      end
      unless q["tags"].nil?
        q["tags"].each do |t|
          t_id = id_conversions[:tags].find { |e| t["id"].eql?(e[:prev_id]) }
          t.extract!("meta") if t["meta"].eql?("new")
          t["id"] = t_id[:id] unless t_id.nil?
        end
      end
      unless q["relations"].nil?
        q["relations"].each do |r|
          r_id = id_conversions[:questions].find { |e| r["id"].eql?(e[:prev_id]) }
          r.extract!("meta") if r["meta"].eql?("new")
          r["id"] = r_id[:id] unless r_id.nil?
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
