Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root 'top_pages#top'

  devise_scope :user do
    delete "logout", to: "users/sessions#destroy", as: :logout
  end
end
