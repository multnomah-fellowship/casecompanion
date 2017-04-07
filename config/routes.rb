Rails.application.routes.draw do
  resources :offenders, only: %i[show index] do
    collection do
      post :search
    end

    get 'notification-systems', to: 'home#notification_systems'
  end

  resource :sessions, only: %i[new create destroy]

  resources :notifications, only: %i[new create]
  get '/n/:id', to: 'notifications#show'

  get '/notification-systems', to: 'home#notification_systems'
  root to: 'home#index'
end
