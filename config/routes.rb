PopUpArchive::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :items

  namespace :directory, as: '', path: '' do
  end

  root to: 'directory/dashboard#guest', constraints: GuestConstraint.new(true)
  root to: 'directory/dashboard#user', constraints: GuestConstraint.new(false)

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
