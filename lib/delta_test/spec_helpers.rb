module DeltaTest
  module SpecHelpers

    def use_delta_test(example)
      $delta_test_generator ||= DeltaTest::Generator.new
      $delta_test_generator.setup!

      example.before(:context) do
        $delta_test_generator.start!(example.metadata[:file_path])
      end

      example.after(:context) do
        $delta_test_generator.stop!
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
