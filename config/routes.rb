Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "logout", to: "users/sessions#destroy", as: :logout
  end

  # TODO: テストが済んだら削除
  post "push_test", to: "push_test#test", as: :push_test

  # static_page関係
  root "top_pages#top"
  get "privacy", to: "static_pages#privacy", as: :privacy
  get "terms", to: "static_pages#terms", as: :terms
  get "tutorial", to: "static_pages#tutorial", as: :tutorial

  # その他モデル
  resources :stocks, except: %i[show] do
    collection do
      get :search
    end
  end
  resources :locations, only: %i[index edit update destroy]
  resources :histories, only: %i[create]
  resources :templetes, only: %i[index create] do
    collection do
      get :form
    end
  end
  resource :partnerships, only: %i[new create update destroy] do
    member do
      delete :reject
    end
  end

  namespace :public do
    resource :partnerships, only: %i[show] do
      member do
        put :approve
        get :approved
        delete :reject
        get :rejected
      end
    end
  end

  # PWA関係
  get "/manifest.json", to: "pwa#manifest", defaults: { format: :json }
  get "/service-worker.js", to: "pwa#service_worker", defaults: { format: :js }
  resources :subscriptions, only: %i[create destroy]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  if Rails.env.production?
    mount ActionCable.server, at: "/cable"
  end
end
