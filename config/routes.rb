PopUpArchive::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :directory, as: '', path: '' do
    resources :items
  end

  namespace :api, defaults: { format: 'json' }, path: 'api' do
    scope module: :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
      root to: 'status#info'

      resources :items
    end
  end

  root to: 'directory/dashboard#guest', constraints: GuestConstraint.new(true)
  root to: 'directory/dashboard#user', constraints: GuestConstraint.new(false)

  unless Rails.env.test?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

end
