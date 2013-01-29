PopUpArchive::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :directory, as: '', path: '' do
    resources :items
  end

  namespace :api, defaults: { format: 'json' }, path: 'api' do
    scope module: :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
      root to: 'status#info'

      resource :upload

      resources :items
      resources :collections
    end
  end

  root to: 'directory/dashboard#guest', constraints: GuestConstraint.new(true)
  root to: 'directory/dashboard#user', constraints: GuestConstraint.new(false)

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
