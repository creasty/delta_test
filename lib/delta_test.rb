require "pathname"

require_relative "delta_test/version"
require_relative "delta_test/configuration"

module DeltaTest

  ACTIVE_FLAG = 'DELTA_TEST_ACTIVE'

  class TableNotFoundError < IOError; end
  class NotInGitRepository < StandardError; end

  class << self

    attr_reader :config

    def setup
      @config = Configuration.new
      @active = (!ENV[ACTIVE_FLAG].nil? && ENV[ACTIVE_FLAG] =~ /0|false/i)
    end

    def configure
      yield @config if block_given?
      @config.precalculate!
    end

    def regulate_filepath(file)
      file = Pathname.new(file)
      file = file.relative_path_from(@config.base_path) rescue file
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
