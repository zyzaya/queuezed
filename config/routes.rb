Rails.application.routes.draw do
  devise_for :users
  resources :quizzes
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/quizzes/:id/practice', to: 'practice_sessions#new'
  
  # Defines the root path route ("/")
  devise_scope :user do
    authenticated do
      root to: 'quizzes#index', as: 'authenticated_root'
    end

    unauthenticated do
      root to: 'devise/sessions#new', as: 'unauthenticated_root'
    end
  end
end
