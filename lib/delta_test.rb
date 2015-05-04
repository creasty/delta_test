require_relative "delta_test/version"
require_relative "delta_test/configuration"
require_relative "delta_test/analyzer"
require_relative "delta_test/dependencies"
require_relative "delta_test/dependencies_table"
require_relative "delta_test/generator"

module DeltaTest
  class << self

    def configure
      @config ||= Configuration.new

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
      @config.respond_to?(method_name)
    end

    def regulate_filepath(file)
      file = Pathname.new(file)
      file = file.relative_path_from(self.base_path) rescue file
      file.cleanpath
    end

  end
end

DeltaTest.configure
