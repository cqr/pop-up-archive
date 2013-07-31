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
# gem 'activerecord-postgres-hstore', github: 'engageis/activerecord-postgres-hstore'
gem 'activerecord-postgres-hstore', '~> 0.6.0'
gem 'postgres_ext'
gem 'acts_as_list'
gem 'multi_json', '~> 1.5.0'

gem 'decent_exposure', '~> 2.1.0'
# gem 'decent_exposure', github: 'voxdolo/decent_exposure'

# login to prx.org using omniauth
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.1.0'
gem 'omniauth-prx', github: 'PRX/omniauth-prx'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'devise'
gem 'devise_invitable', github: 'scambra/devise_invitable'
gem 'bootstrap_form'
gem 'cancan'

# search with elasticsearch
gem 'tire'

# server-side templates
gem 'slim-rails', '~> 1.0'
gem 'rabl'

# background processing
gem 'sidekiq'

# misc
gem 'copyrighter'
gem 'geocoder'
gem 'will_paginate'

gem 'carrierwave'

gem 'fog', '~> 1.11.1'

gem 'heroku-api', '~> 0.3.10'
gem 'excon', '~> 0.21.0'

gem 'pb_core', '~> 0.1.5'
# gem 'pb_core', path: '~/dev/projects/pb_core'

gem 'chronic'

gem 'state_machine'

gem 'doorkeeper'

gem "acts_as_paranoid", "~>0.4.0"

gem 'newrelic_rpm'

group :assets do
  gem 'sprockets'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
  gem 'angularjs-rails-resource'
  gem 'font-awesome-sass-rails', github: 'pduersteler/font-awesome-sass-rails'
end

group :development do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ruby_gntp'
  gem 'guard-rspec'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.4'
  gem 'listen'
  gem 'terminal-notifier-guard'
  gem 'growl', require: false
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'spring'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'spork-rails'
  gem 'shoulda-matchers'
end

group :development, :production, :staging do
  gem 'sinatra' # for sidekiq
  gem 'autoscaler', '~> 0.2.0'
  gem 'foreman'
  gem 'thin'
end
