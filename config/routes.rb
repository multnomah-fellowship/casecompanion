# frozen_string_literal: true

Rails.application.routes.draw do
  get '/offenders/:jurisdiction/:id' => 'offenders#show', as: :offender
  post '/offenders/:jurisdiction' => 'offender_jurisdictions#search'
  get '/offenders/:jurisdiction' => 'offender_jurisdictions#show', as: :offender_jurisdiction
  get '/offenders/:id', to: redirect('/offenders/oregon/%<id>') # deprecated!

  get '/offenders', to: 'offender_jurisdictions#index', as: :offenders
  post '/offenders/:jurisdiction', to: 'offender_jurisdictions#search'

  get '/feedback/:id' => 'feedback_responses#show', id: /\d+/
  get '/feedback/:type' => 'feedback_responses#create', as: :feedback_response
  patch '/feedback/:id' => 'feedback_responses#update'

  get '/beta', to: 'beta_signups#new', as: :beta_signup
  post '/beta', to: 'beta_signups#create', as: :beta_signups
  get '/beta/download', to: 'beta_signups#index', as: :beta_signups_download

  resources :rights, only: %i[show index create destroy], id: Regexp.union(RightsFlow::PAGES) do
    collection do
      post '/:id', to: 'rights#update'
      delete '/', to: 'rights#delete'
    end
  end

  resources :court_case_subscriptions, as: :subscription, only: %i[show]

  resources :faqs, only: %i[show index]

  resource :styleguide, only: %i[show]

  resource :sessions, only: %i[new create destroy]
  resources :users, only: %i[edit update] do
    resources :court_case_subscriptions, only: %i[create destroy]
  end

  get '/t/:tracking_id', to: 'home#set_tracking'

  get '/trigger-error', to: 'home#trigger_error'
  get '/sandbox', to: 'home#sandbox'
  get '/home', to: 'home#home'

  root to: 'home#splash'
end
