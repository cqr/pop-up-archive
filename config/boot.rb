require 'rubygems'

# Set up the environment
ENV['ENV_OVERRIDE_FILE'] ||= File.expand_path('../env_vars', __FILE__)

if File.exists?(ENV['ENV_OVERRIDE_FILE'])
  File.open(ENV['ENV_OVERRIDE_FILE']) do |file|
    while line = file.gets
      line.chomp!
      var, val = line.split('=', 2)

      # If it's likely that we previously set DATABASE_URL from this file
      # and we are in the test environment, we need to unset it or else
      # rails will use it but not perform automatic transactions for us during
      # our test suite.
      if var == 'DATABASE_URL' && ENV['RAILS_ENV'] == 'test'
        ENV['DATABASE_URL'] &&= nil
      else
        ENV[var] = val
      end
    end
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
