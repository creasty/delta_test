$_delta_test_generator = DeltaTest::Generator.new

unless defined?(DELTA_TEST_DRYRUN)
  $_delta_test_generator.setup!
  at_exit { $_delta_test_generator.teardown! }
end

module DeltaTest
  module SpecHelpers

    def use_delta_test(example)
      example.before(:context) do
        $_delta_test_generator.start!(example.metadata[:file_path])
      end

      example.after(:context) do
        $_delta_test_generator.stop!
      end
    end

    def self.extended(example)
      example.use_delta_test(example)
    end

    def self.included(example)
      example.extend(self)
    end

  end
end
