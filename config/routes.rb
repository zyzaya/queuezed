Rails.application.routes.draw do
  devise_for :users
  resources :quizzes
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "quizzes#index"
end
