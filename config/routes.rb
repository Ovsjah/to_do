Rails.application.routes.draw do
  root 'sessions#new'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users, only: %i[show edit update destroy]
  resources :todos, :tasks, except: %i[index show]
end
