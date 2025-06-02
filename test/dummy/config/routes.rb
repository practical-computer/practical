# frozen_string_literal: true

Rails.application.routes.draw do
  get "membership_invitations/show"
  get "membership_invitations/create_user_and_use"
  get "membership_invitations/accept_as_current_user"
  get "membership_invitations/sign_out_then_show"
  default_url_options protocol: :https

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }, sign_out_via: [:get, :delete]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  devise_scope :user do
    post 'sign_up/new_challenge', to: 'users/registrations#new_challenge', as: :new_user_registration_challenge
    post 'sign_in/new_challenge', to: 'users/sessions#new_challenge', as: :new_user_session_challenge

    authenticated(:user) do
      post('reauthenticate/new_challenge', to: 'users/reauthentication#new_challenge',
                                           as: :new_user_reauthentication_challenge
          )
      post 'reauthenticate', to: 'users/reauthentication#reauthenticate', as: :user_reauthentication
    end

    namespace :users, as: :user do
      resources :emergency_passkey_registrations, only: [:new, :create, :show] do
        member do
          patch :use
          post :new_challenge
        end
      end

      authenticated(:user) do
        resources :passkeys, only: [:create, :destroy] do
          collection do
            post :new_create_challenge
          end

          member do
            post :new_destroy_challenge
          end
        end
      end
    end
  end

  resources :membership_invitations, only: [:show] do
    member do
      post :new_create_challenge
      post :create_user_and_use
      delete :sign_out_then_show

      authenticated(:user) do
        patch :accept_as_current_user
      end
    end
  end

  authenticated(:user) do
    resources :organizations, only: [:index, :show]
  end

  # Defines the root path route ("/")
  root "root#index"
end
