Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  devise_for :users,
    path: "api/v1",
    path_names: { sign_in: "login", sign_out: "logout", registration: "signup" },
    controllers: {
      sessions: "api/v1/sessions",
      registrations: "api/v1/registrations"
    },
    defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      post "refresh", to: "refresh_tokens#create"
      resource :profile, only: [ :show ], path: "me"
      resources :users, only: [ :index, :show, :update, :destroy ]
      resources :audit_logs, only: [ :index ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
