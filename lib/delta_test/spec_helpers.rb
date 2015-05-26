require_relative 'generator'

module DeltaTest
  module SpecHelpers

    ###
    # Setup generator and hook profiler on contexts
    ###
    def use_delta_test(example)
      generator = DeltaTest::GeneratorSingleton.instance
      generator.setup!

      example.before(:all) do
        generator.start!(example.file_path)
      end

      example.after(:all) do
        generator.stop!
      end

      generator.hook_on_exit
    end

    ###
    # Extend
    #
    # @params {} example
    ###
    def self.extended(example)
      example.use_delta_test(example)
    end

    ###
    # Include
    # calls `extend` internally
    #
    # @params {} example
    ###
    def self.included(example)
      example.extend(self)
    end

  end
end
