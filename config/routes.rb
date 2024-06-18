Rails.application.routes.draw do
  devise_for :users
  resources :quizzes, shallow: true, only: [:index, :show, :edit, :update] do
    resources :questions, only: [:index, :new, :show, :edit, :update, :destroy]
    resources :practice, only: [:new], controller: 'practice_sessions' do
      resources :answers, only: [:new, :create], controller: 'answer_histories'
      resources :practice_questions, only: [:show]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
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
