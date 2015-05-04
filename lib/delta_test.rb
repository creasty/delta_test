require_relative "delta_test/version"
require_relative "delta_test/analyzer"
require_relative "delta_test/dependencies_table"

module DeltaTest

  class Configuration

    attr_accessor *%i[
      base_path
      table_file
      files
    ]

    def initialize
      @base_path  = "/"
      @table_file = "tmp/.delta_test_dt"
      @files      = []

      if defined?(Rails)
        @base_path  = Rails.root.to_s
        @files     |= Rails.application.send(:_all_load_paths)
      end
    end

  end

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

  end

end

DeltaTest.configure
