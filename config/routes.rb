Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks"
  }

  get "up" => "rails/health#show", :as => :rails_health_check

  root "home#index"

  ###############
  ###   API22  ###
  ###############

  namespace :api do
  end
end
