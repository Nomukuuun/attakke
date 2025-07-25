Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root 'top_pages#top'
  resources :stocks, except: %i[show]

  devise_scope :user do
    delete "logout", to: "users/sessions#destroy", as: :logout
  end
end
