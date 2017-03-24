Rails.application.routes.draw do
  resource :sessions, only: %i[new create destroy]

  resources :notifications, only: %i[new create]

  root to: 'home#index'
end
