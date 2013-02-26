source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '~> 3.2.0'

# Rails 4 pre-prep
gem 'strong_parameters'
gem 'routing_concerns'
gem 'etagger', github: 'rails/etagger'
gem 'cache_digests'
gem 'dalli'

gem 'media_monster_client'
gem 'pg'
gem 'activerecord-postgres-hstore', github: 'engageis/activerecord-postgres-hstore'
gem 'postgres_ext'
gem 'acts_as_list'
gem 'multi_json', "~> 1.5.0"

group :assets do
  gem 'sprockets'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
  gem 'angularjs-rails-resource'
  gem "font-awesome-sass-rails"
  gem 'angular-rails', github: 'gistia/angular-rails'
end

group :development do
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

# login to prx.org using omniauth
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.1.0'
gem "omniauth-prx", github: 'PRX/omniauth-prx'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'devise'
gem 'bootstrap_form'

# search with elasticsearch
gem 'tire'

# server-side templates
gem 'slim-rails'
gem 'rabl'

# background processing
gem 'sidekiq'

group :development, :production do
  gem 'sinatra' # for sidekiq
  gem "autoscaler", "~> 0.2.0"
  gem "foreman"
  gem "thin"
end

# misc
gem 'copyrighter'
gem 'geocoder'
gem 'will_paginate'

gem 'carrierwave'
gem 'fog'

gem 'pb_core', :path=>'~/dev/projects/pb_core'

