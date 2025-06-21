Rails.application.routes.draw do
  resources :governing_bodies
  resources :area_of_concerns
  resources :governance_types
  resources :voter_election_baselines
  resources :ratings

  devise_for :voters
  resources :voters
  resources :residences
  resources :candidacies
  resources :people
  resources :elections
  resources :years
  resources :offices do
    resources :elections, only: [:index]
  end
  resources :positions
  resources :cities
  resources :states
  resources :countries do
    resources :states, only: [:index]
  end

  resources :mountains, only: [:index, :show, :edit, :update] do
    member do
      post :simulate
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "countries#index"
end
