require 'rspec'
require 'delta_test'

Dir["#{File.dirname(__FILE__)}/supports/**/*.rb"].each { |f| require f }


module DeltaTestSpecHelper

  def support_path(*path)
    File.expand_path(File.join('supports', *path), File.dirname(__FILE__))
  end

end


RSpec.configure do |config|

  config.include DeltaTestSpecHelper

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end
