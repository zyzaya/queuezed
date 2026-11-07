module ApplicationHelper
    def is_guest
        !session[:guest_user_id].nil?
    end
end
