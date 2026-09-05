# frozen_string_literal: true

require 'simplecov'

# Start SimpleCov
SimpleCov.start do
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter])
  skip 'spec/'
end

# Load Rails dummy app
ENV['RAILS_ENV'] = 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

# Load test gems
require 'rspec/rails'

# Load our own config
require_relative 'config_rspec'

# Load test helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
