require 'rspec'
require 'fakefs/spec_helpers'

require 'delta_test'

Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/supports/**/*.rb"].each { |f| require f }


module DeltaTestSpecHelper

  def fixture_path(*path)
    File.expand_path(File.join('fixtures', *path), File.dirname(__FILE__))
  end

end


RSpec.configure do |config|

  config.include DeltaTestSpecHelper
  config.include FakeFS::SpecHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after do
    DeltaTest.setup
  end

end
