Rails.application.routes.draw do
  get "glossary" => "pages#glossary", as: :glossary
  get "supporters" => "pages#supporters", as: :supporters
  get "approval-voting" => "pages#approval_voting", as: :approval_voting
  resources :engagements, only: [:index, :create, :destroy], path: "saved"
  resources :official_codes
  resources :policies do
    resources :official_codes, only: [:index]
  end
  resources :stances
  resources :approaches
  resources :issues do
    resources :approaches, only: [:index]
  end
  resources :topics do
    resources :issues, only: [:index]
  end
  resources :governing_bodies do
    resources :policies, only: [:index]
  end
  resources :area_of_concerns
  resources :governance_types do
    resources :governing_bodies, only: [:index]
  end
  resources :voter_race_baselines
  resources :ratings

  devise_for :voters
  resources :voters
  resources :residences
  resources :candidacies
  resources :people
  resources :elections do
    resources :races, only: [:index]
  end
  resources :races
  resources :years
  resources :offices do
    resources :races, only: [:index]
  end
  resources :positions
  resources :municipalities
  resources :counties
  resources :districts
  resources :states do
    resources :municipalities, only: [:index]
  end
  resources :countries do
    resources :states, only: [:index]
  end

  resources :mountains, only: [:index, :show, :edit, :update] do
    member do
      post :simulate
      patch :primary_candidates
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Development only: serve SimpleCov coverage reports
  if Rails.env.development?
    mount Rack::Files.new(Rails.root.join('coverage')), at: '/coverage'
    mount Rack::Files.new(Rails.root.join('app/assets/builds')), at: '/dev-assets'
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
