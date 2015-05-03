$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rspec'
require 'delta_test'

Dir["#{File.dirname(__FILE__)}/supports/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
end
