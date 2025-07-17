require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks"
  }

  get "up" => "rails/health#show", :as => :rails_health_check

  # 👇 Define root diferente para logado e não logado
  authenticated :user do
    root to: "closings#index", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/users/sign_in")
  end

  resources :closings, only: %i[index create update] do
    get :closing_audit, on: :collection
    get :deposits_in_banks, on: :collection
    post :modify_for_this_closure, on: :collection
    get :note_divisions, on: :collection
    post :perform_closing, on: :member
    get :download_pdf, on: :collection
  end

  resources :current_accounts, only: %i[index create update destroy] do
    post :change_standard, on: :member
  end

  resources :branches, only: %i[index create update destroy] do
    get :print_all_stores, on: :collection
    get :download_pdf, on: :collection
  end

  resources :prescribers, only: %i[index create update show destroy] do
    post :change_accumulated, on: :member
    get :patient_listing, on: :member
  end

  resources :representatives, only: %i[index create update] do
    post :change_active, on: :member
    get :monthly_report, on: :member
    get :patient_listing, on: :member
    get :select, on: :collection
    get :summary_patient_listing, on: :member
    get :unaccumulated_addresses, on: :member
    get :download_pdf, on: :member
    get :download_select_pdf, on: :collection
  end

  # API namespace (mantido vazio por enquanto)
  namespace :api do
  end
end
