require 'rubygems'
require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  require "rails/application"

  Spork.trap_method(Rails::Application, :reload_routes!)
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  RSpec.configure do |config|
    config.mock_with :rspec

    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  FactoryGirl.reload
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end
