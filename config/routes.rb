Rails.application.routes.draw do
  resources :offenders, only: %i[show]
  resource :sessions, only: %i[new create destroy]

  resources :notifications, only: %i[new create]

  root to: 'home#index'
end
