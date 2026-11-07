class ApplicationController < ActionController::Base  
  # before_action :transfer_guest_to_user
  protect_from_forgery with: :exception, prepend: true
  helper_method :is_guest

  def current_or_guest_user
    if current_user
      puts "#{session[:guest_user_id]}, #{current_user.id}"
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:reload).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      puts "creating guest user"
      guest_user
    end
  end

  def guest_user(with_retry = true)
    puts "cu: #{current_user}"
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound
    session[:guest_user_id] = nil
    guest_user if with_retry
  end

  def is_guest
    !session[:guest_user_id].nil?
  end

  def transfer_guest_to_user
    current_or_guest_user
  end

  private

  def logging_in
    guest_user.quizzes.update_all(user_id: current_user.id)
    puts "logging in"
  end

  def create_guest_user
    u = User.new(email: "guest_#{Time.now.to_i}#{rand(100)}@example.com")
    u.save!(validate: false)
    session[:guest_user_id] = u.id
    puts "cu: #{current_user}"
    u
  end
end
