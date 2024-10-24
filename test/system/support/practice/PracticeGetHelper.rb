module PracticeGetHelper
  def get_practice(q_id, initial)
    sessions = Quiz.find(q_id).practice_sessions.pluck(:id)
    id = (sessions - initial)[0]
    return PracticeSession.find(id)
  end
end