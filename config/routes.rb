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

  resources :closings, only: %i[index show create update destroy] do
    post :modify_for_this_closure, on: :collection
  end

  resources :representatives, only: %i[index show create update destroy]

  ###############
  ###   API22  ###
  ###############

  namespace :api do
  end
end
