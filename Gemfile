source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '~> 3.2.0'

# Rails 4 pre-prep
gem 'strong_parameters'
gem 'routing_concerns'
gem 'etagger', git: 'git://github.com/rails/etagger.git'
gem 'cache_digests'
gem 'dalli'

gem 'pg'
gem 'activerecord-postgres-hstore', github: 'engageis/activerecord-postgres-hstore'
gem 'postgres_ext'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

group :development do
  gem 'debugger'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ruby_gntp'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'rb-fsevent', '~> 0.9.1'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'spork-rails'
  gem 'shoulda-matchers'
end

gem 'decent_exposure'
gem 'jquery-rails'

# login to prx.org using omniauth
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.0.0'
gem "omniauth-prx", git: 'git://github.com/PRX/omniauth-prx.git'
gem 'devise'

# search with elasticsearch
gem 'tire'

# server-side templates
gem 'slim-rails'
gem 'rabl'

# angular-js for client-side application
gem 'angular-rails', git: 'https://github.com/gistia/angular-rails'

# background processing
gem 'sidekiq'

group :development, :production do
  gem 'sinatra' # for sidekiq
end

# misc
gem 'copyrighter'
gem 'geocoder'
gem 'will_paginate'
