require 'rubygems'
require 'spork'

Spork.prefork do
  require File.expand_path('../../config/environment', __FILE__)
  require 'rspec/rails'

  require 'delta_test'
  require 'delta_test/spec_helpers'

  RSpec.configure do |config|

    ENV['RAILS_ENV'] ||= 'test'

    config.include DeltaTest::SpecHelpers
    config.include FactoryGirl::Syntax::Methods

    config.expect_with :rspec do |expectations|
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = true
    end

    config.before :each do |example|
      DatabaseCleaner.strategy = if example.metadata[:js]
          :truncation
        else
          :transaction
        end

      DatabaseCleaner.start
    end

    config.after :each do
      DatabaseCleaner.clean
    end

  end
end

Spork.each_run do
  if Spork.using_spork?
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
    Rails.application.reload_routes!
    FactoryGirl.reload
  end
end
