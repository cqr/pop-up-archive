ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require "rails/application"
require 'factory_girl'
require 'rspec/rails'

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true

  config.include Devise::TestHelpers, type: :controller
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f }
  FactoryGirl.reload
end
