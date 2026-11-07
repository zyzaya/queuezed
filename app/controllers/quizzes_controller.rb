class QuizzesController < ApplicationController
  # before_action :authenticate_user!

  def index
    @quizzes = current_or_guest_user.quizzes.includes(:questions).order(:created_at)
    @difficult_counts = Question.where(quiz_id: @quizzes, difficult: true, deleted_at: nil).group(:quiz_id).count
    @review_counts = Question.review.where(quiz_id: @quizzes, deleted_at: nil).group(:quiz_id).count
  end

  def create
    @quiz = current_or_guest_user.quizzes.create(name: "New Quiz")
    render "quizzes/edit"
  end

  def edit
    @quiz = current_or_guest_user.quizzes.find_by(id: params[:id])
    if (@quiz.nil?)
      head :not_found
    else
      @difficult_count = @quiz.questions.where(difficult: true).count
      @review_count = @quiz.questions.review.count
    end
  end

  def destroy
    quiz = current_or_guest_user.quizzes.find_by(id: params[:id])
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
    quiz = current_or_guest_user
      .quizzes
      .includes(questions: [:answers])
      .find_by(id: params[:id])
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
            ids = update_quiz(quiz, quiz_params)
            quiz.save
            result_quiz = current_or_guest_user
              .quizzes
              .includes(questions: [:answers, :tags])
              .find_by(id: quiz.id)
            result = inject_id_conversion(result_quiz, ids)
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

  def update_quiz(quiz, quiz_params)
    ids = {
      questions: [],
      answers: [],
      tags: [],
    }
    quiz.name = quiz_params["name"] unless quiz_params["name"].nil?
    unless quiz_params["questions"].nil?
      q_ids = quiz_params["questions"]&.map do |q| 
        ret = [q["id"]]
        q["relations"]&.each { |r| ret << r["id"] }
        ret
      end
      q_ids = q_ids.flatten.compact.uniq
      questions = []
      Answer.unscoped do
        questions = quiz
          .questions
          .unscope(where: :deleted_at)
          .includes(:answers)
          .where(id: q_ids)
          .to_ary
      end
      all_tags = quiz.tags.unscope(where: :deleted_at)
      new_tags = []
  
      quiz_params["questions"]&.each do |q|
        question = questions.find { |e| e.id == q["id"] }
        raise ActiveRecord::RecordNotFound if question.nil? && !q["meta"].eql?("new")
        # delete question
        if q["meta"].eql?("delete")
          question.soft_destroy
        # create new question
        elsif q["meta"].eql?("new") && question.nil?
          question = quiz.questions.create(content: q["content"])
          ids[:questions] << {id: question.id, prev_id: q["id"] }
          questions << question
          q["answers"]&.each { |a| update_answer(question, a, ids) }
          q["tags"]&.each { |t| update_tag(all_tags, new_tags, question, t, ids) }
        # restore question
        elsif q["meta"].eql?("new") && !question.nil?
          question.restore
          question.update(content: q["content"]) unless q["content"].nil?
          q["answers"]&.each { |a| update_answer(question, a, ids) }
          q["tags"]&.each { |t| update_tag(all_tags, new_tags, question, t, ids) }
        # update question
        else
          question.update(content: q["content"]) unless q["content"].nil?
          q["answers"]&.each { |a| update_answer(question, a, ids) }
          q["tags"]&.each { |t| update_tag(all_tags, new_tags, question, t, ids) }
        end
      end
      # relations
      quiz_params["questions"]&.each do |q|
        q_id = ids[:questions].find { |e| e[:prev_id].eql?(q["id"]) }
        q_id = q_id.nil? ? q["id"] : q_id[:id]
        question = questions.find { |e| e.id == q_id }
        q["relations"]&.each do |r|
          update_relation(questions, question, r, ids)
        end
      end
    end
    return ids
  end

  def update_answer(question, a, ids)
    answer = question.answers.find { |e| e.id == a["id"] }
    raise ActiveRecord::RecordNotFound if answer.nil? && !a["meta"].eql?("new")
    if a["meta"].eql?("delete")
      answer.soft_destroy
    elsif a["meta"].eql?("new") && answer.nil?
      answer = question.answers.create(content: a["content"])
      ids[:answers] << {question_id: question.id, id: answer.id, prev_id: a["id"]}
    elsif a["meta"].eql?("new") && !answer.nil?
      answer.restore
      answer.update(content: a["content"]) unless a["content"].nil?
    else
      answer.update(content: a["content"]) unless a["content"].nil?
    end
  end

  def update_tag(all_tags, new_tags, question, t, ids)
    t_id = ids[:tags].find { |e| e[:prev_id].eql?(t["id"]) }
    t_id = t_id.nil? ? t["id"] : t_id[:id]
    tag = all_tags.find { |e| e.id == t_id }
    tag = new_tags.find { |e| e.id == t_id} if tag.nil?
    raise ActiveRecord::RecordNotFound.new if tag.nil? && !t["meta"].eql?("new") && !t["meta"].eql?("add")
    if t["meta"].eql?("new") || t["meta"].eql?("add")
      if tag.nil?
        tag = question.tags.create(content: t["content"])
        new_tags << tag
        ids[:tags] << { question_id: question.id, id: tag.id, prev_id: t["id"] }
      else
        question.tags << tag
      end
    elsif t["meta"].eql?("delete") || t["meta"].eql?("remove")
      question.tags.delete(tag) unless tag.nil?
    end
  end

  def update_relation(questions, question, r, ids)
    r_id = ids[:questions].find { |e| e[:prev_id].eql?(r["id"]) }
    r_id = r_id.nil? ? r["id"] : r_id[:id]
    relation = questions.find { |e| e.id == r_id }
    if r["meta"].eql?("new") || r["meta"].eql?("add")
      question.relations << relation unless relation.nil?
    elsif r["meta"].eql?("delete") || r["meta"].eql?("remove")
      question.relations.delete(relation) unless relation.nil?
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
