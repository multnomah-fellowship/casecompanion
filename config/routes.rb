Rails.application.routes.draw do
  resources :offenders, only: %i[show index] do
    collection do
      post :search
    end
  end

  resource :sessions, only: %i[new create destroy]

  resources :notifications, only: %i[new create]
  get '/n/:id', to: 'notifications#show'

  root to: 'home#index'
end
