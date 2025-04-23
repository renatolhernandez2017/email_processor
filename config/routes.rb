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
    get :closing_audit, on: :collection
    get :deposits_in_banks, on: :collection
    post :modify_for_this_closure, on: :collection
    get :note_divisions, on: :collection
  end

  resources :current_accounts, only: %i[index create update destroy] do
    post :change_standard, on: :member
  end

  resources :branches, only: %i[index create update destroy] do
    get :print_all_stores, on: :collection
  end

  resources :discounts, only: %i[index create update destroy]

  resources :prescribers, only: %i[index create update show destroy] do
    post :change_accumulated, on: :member
    get :patient_listing, on: :member
    patch :requests, on: :member
  end

  resources :representatives, only: %i[index create update] do
    get :monthly_report, on: :member
    get :patient_listing, on: :member
    get :summary_patient_listing, on: :member
    get :unaccumulated_tags, on: :member
    get :unaccumulated_addresses, on: :member
  end

  ###############
  ###   API22  ###
  ###############

  namespace :api do
  end
end
