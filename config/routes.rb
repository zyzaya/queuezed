Rails.application.routes.draw do
  devise_for :users
  resources :quizzes, shallow: true, only: [:index, :show, :edit, :update] do
    resources :questions, only: [:index, :new, :show, :edit, :update, :destroy]
    resources :practice_sessions, only: [:new], controller: 'practice_sessions' do
      resources :answers, only: [:new, :create], controller: 'answer_histories'
      resources :practice_questions, only: [:show]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # quizzes/id/practice
  # quizzes/id/practice/id/answers/new
  # quizzes/id/practice/id/answer/new

  # quizzes/id/practice/id/questions/id
  
  # question resource
  # quizzes/id/questions
  # quizzes/id/questions/new
  # quizzes/id/questions/id
  # quizzes/id/questions/id/edit
  # quizzes/id/questions/id
  
  
  
  # get '/quizzes/:id/practice', to: 'practice_sessions#new'
  # get '/quizzes/:quiz_id/practice/:session_id/answers/new', to: 'answer_histories#new'
  # post '/quizzes/:quiz_id/practice/:session_id/answers/new', to: 'answer_histories#create'

  # get '/quizzes/:id/:practice_session_id/practice_questions/:practice_question_id', to: 'practice_questions#show'
  # get '/quizzes/:quiz_id/practice/:session_id/questions/:question_id', to: 'practice_questions#show'
  
  # get '/quizzes/:quiz_id/questions', to: 'questions#index'
  # get '/quizzes/:quiz_id/edit/questions/:question_id/edit', to: 'questions#edit'
  # put '/quizzes/:quiz_id/edit/questions/:question_id', to: 'questions#update'
  # get '/quizzes/:quiz_id/edit/questions/new', to: 'questions#new'
  # delete '/quizzes/:quiz_id/edit/questions/:question_id', to: 'questions#delete'

  # post '/quizzes/:quiz_id/update', to: 'quizzes#update'

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
