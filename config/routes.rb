Rails.application.routes.draw do
  devise_for :users
  resources :quizzes
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/quizzes/:id/practice', to: 'practice_sessions#new'
  get '/quizzes/:quiz_id/practice/:session_id/answers/new', to: 'answer_histories#new'
  post '/quizzes/:quiz_id/practice/:session_id/answers/new', to: 'answer_histories#create'

  get '/quizzes/:id/:practice_session_id/practice_questions/:practice_question_id', to: 'practice_questions#show'
  get '/quizzes/:quiz_id/practice/:session_id/questions/:question_id', to: 'practice_questions#show'
  
  get '/quizzes/:quiz_id/edit/questions/:question_id/edit', to: 'questions#edit'
  get '/quizzes/:quiz_id/edit/questions/new', to: 'questions#new'
  delete '/quizzes/:quiz_id/edit/questions/:question_id', to: 'questions#delete'

  post '/quizzes/:quiz_id/update', to: 'quizzes#update'

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
