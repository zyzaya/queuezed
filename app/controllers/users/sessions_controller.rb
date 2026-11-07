class Users::SessionsController < Devise::SessionsController
    skip_before_action :require_no_authentication, only: [:new, :create]
    before_action :authenticate_guest, only: [:new, :create]

    def create
        if is_guest
        end
        super
    end 

    private

    def authenticate_guest
        require_no_authentication unless is_guest
    end
end