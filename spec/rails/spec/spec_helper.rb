require 'rubygems'
require 'spork'

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  require File.expand_path('../../config/environment', __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/poltergeist'

  require 'delta_test'
  require 'delta_test/spec_helpers'

  RSpec.configure do |config|

    config.include DeltaTest::SpecHelpers
    config.include FactoryGirl::Syntax::Methods

    Capybara.javascript_driver = :poltergeist
    Capybara.default_selector  = :css
    Capybara.default_wait_time = 15

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: true, timeout: 90)
    end

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
