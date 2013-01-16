source 'https://rubygems.org'

gem 'rails', '3.2.10'

gem 'pg'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
end

group :development, :test do  
  gem 'rspec-rails', '~> 2.0'
  gem 'debugger'
end  

group :test do  
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'guard-rspec'
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'rb-fsevent', '~> 0.9.1'
end  

gem 'jquery-rails'

gem 'oauth'
gem 'oauth2'
gem 'oauth-plugin', '~> 0.4.0'

# login to prx.org using omniauth
gem 'omniauth'
gem "omniauth-oauth2", "~> 1.0.0"
gem "omniauth-prx", :git=>'git://github.com/PRX/omniauth-prx.git'

# search with elasticsearch
gem 'tire'

# server-side templates
gem 'slim-rails'