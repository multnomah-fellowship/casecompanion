Rails.application.routes.draw do
  resource :sessions, only: %i[new create destroy]

  root to: 'home#index'
end
