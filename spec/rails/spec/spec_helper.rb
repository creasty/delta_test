require "delta_test"
require "delta_test/spec_helpers"

DeltaTest.configure do |config|
  config.base_path = File.expand_path('../..', __FILE__)  # hack
end

RSpec.configure do |config|

  config.include DeltaTest::SpecHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end
