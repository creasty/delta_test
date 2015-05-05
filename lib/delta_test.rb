require_relative "delta_test/version"
require_relative "delta_test/git"
require_relative "delta_test/configuration"
require_relative "delta_test/analyzer"
require_relative "delta_test/dependencies"
require_relative "delta_test/dependencies_table"
require_relative "delta_test/generator"

module DeltaTest

  ACTIVE_FLAG = 'DELTA_TEST_ACTIVE'

  class << self

    def setup
      @config = Configuration.new
      @active = (!ENV[ACTIVE_FLAG].nil? && ENV[ACTIVE_FLAG] =~ /0|false/i)
    end

    def configure
      yield @config if block_given?
    end

    def method_missing(method_name, *args, &block)
      if @config.respond_to?(method_name)
        @config.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      @config.respond_to?(method_name) || super
    end

    def regulate_filepath(file)
      file = Pathname.new(file)
      file = file.relative_path_from(self.base_path) rescue file
      file.cleanpath
    end

    def active?
      @active
    end

    def activate!
      @active = true
    end

    def deactivate!
      @active = false
    end

  end
end

DeltaTest.setup
