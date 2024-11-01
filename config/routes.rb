Rails.application.routes.draw do
  devise_for :users
  resources :quizzes, shallow: true, only: [:index, :create, :edit, :update, :destroy] do
    resources :questions, only: [:index, :new, :show, :edit, :destroy]
    resources :practice, only: [:show, :new, :create], controller: 'practice_sessions' do
      resources :answers, only: [:new, :create], controller: 'question_histories'
    end
  end

  post 'practice/:id/finish', to: 'practice_sessions#finish', as: :practice_finish
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
