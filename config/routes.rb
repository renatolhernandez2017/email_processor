Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks"
  }

  get "up" => "rails/health#show", :as => :rails_health_check

  root "closings#index"

  resources :closings, only: %i[index create update] do
    post :modify_for_this_closure, on: :collection
  end

  resources :current_accounts, only: %i[index create update destroy] do
    post :change_standard, on: :member
  end

  resources :branches, only: %i[index create update destroy]
  resources :discounts, only: %i[index create update destroy]
  resources :prescribers, only: %i[index create update show destroy]

  resources :representatives, only: %i[index create update] do
    get :monthly_report, on: :member
    get :patient_listing, on: :member
  end

  ###############
  ###   API22  ###
  ###############

  namespace :api do
  end
end
