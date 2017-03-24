Rails.application.routes.draw do
  resources :sessions, only: %i[new create]
  root to: 'home#index'
end
