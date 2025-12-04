require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks"
  }

  get "up" => "rails/health#show", :as => :rails_health_check

  root "pages#home"

  resources :email_files, only: [:new, :create, :index] do
    collection do
      get  "/upload", to: "email_files#upload", as: :upload_emails
      post "/upload", to: "email_files#process_file", as: :process_emails
    end
  end

  resources :customers, only: [:index, :show]
  resources :processing_logs, only: [:index, :show]

  # API namespace (mantido vazio por enquanto)
  namespace :api do
  end

  mount ActionCable.server => "/cable"
end
