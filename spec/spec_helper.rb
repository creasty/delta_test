require 'rspec'
require 'pry'
require 'fakefs/spec_helpers'
require 'codeclimate-test-reporter'

require 'delta_test'

Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/supports/**/*.rb"].each { |f| require f }

Pry.config.history.should_load = false
Pry.config.history.should_save = false

module DeltaTestSpecHelper

  def fixture_path(*path)
    File.expand_path(File.join('fixtures', *path), File.dirname(__FILE__))
  end

end

CodeClimate::TestReporter.start

RSpec.configure do |config|

  config.include DeltaTestSpecHelper
  config.include FakeFS::SpecHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.warn_about_potential_false_positives = false
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before do
    DeltaTest.active  = false
    DeltaTest.verbose = false

    allow_any_instance_of(DeltaTest::Git).to receive(:git_repo?).and_return(true)

    allow($stdout).to receive(:puts).with(any_args).and_return(nil)
    allow($stderr).to receive(:puts).with(any_args).and_return(nil)
  end

end
