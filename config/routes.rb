PopUpArchive::Application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :api, defaults: { format: 'json' }, path: 'api' do
    scope module: :v1, constraints: ApiVersionConstraint.new(version: 1, default: true) do
      root to: 'status#info'

      get '/me' => 'users#me'
      get '/users/me' => 'users#me'

      resource :search
      resources :items do
        resources :audio_files do
          post '', action: 'update'
          get 'transcript_text', action: 'transcript_text'
        end
      end
      resources :collections do
        collection do
          resources :public_collections, path: 'public', only: [:index]
        end
        resources :items
      end
      resources :csv_imports
    end
  end

  unless Rails.env.test?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  match '*path', to: 'directory/dashboard#user', constraints: HtmlRequestConstraint.new()
  root to: 'directory/dashboard#guest', constraints: GuestConstraint.new(true)
  root to: 'directory/dashboard#user', constraints: GuestConstraint.new(false)
end
