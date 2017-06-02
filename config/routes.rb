Rails.application.routes.draw do
  resources :offenders, only: %i[show index] do
    collection do
      post :search
    end
  end

  resources :faqs, only: %i[show index]

  resource :styleguide, only: %i[show]

  resource :sessions, only: %i[new create destroy]
  resources :users, only: %i[edit update]

  resources :notifications, only: %i[new create]
  get '/n/:id', to: 'notifications#show'
  get '/t/:tracking_id', to: 'home#set_tracking'

  get '/trigger-error', to: 'home#trigger_error'
  get '/sandbox', to: 'home#sandbox'
  get '/home', to: 'home#home'

  root to: 'home#splash'
end
