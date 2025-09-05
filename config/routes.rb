Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  devise_scope :user do
    delete "logout", to: "users/sessions#destroy", as: :logout
  end

  root 'top_pages#top'
  resources :stocks, except: %i[show] do
    collection do
      get :in_stocks
      get :out_of_stocks
    end
  end
  resources :locations, except: %i[index show]
  resources :histories, only: %i[create]
  resources :templetes, only: %i[index create]
  resource  :partnerships, only: %i[new create update destroy] do
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

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
