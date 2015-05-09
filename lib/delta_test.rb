require 'pathname'

require_relative 'delta_test/version'
require_relative 'delta_test/configuration'

module DeltaTest

  ACTIVE_FLAG = 'DELTA_TEST_ACTIVE'

  class TableNotFoundError < IOError; end
  class NotInGitRepository < StandardError; end
  class NoConfigurationFileFound < IOError; end
  class InvalidOption < StandardError; end

  class << self

    attr_reader :config

    def setup
      @config = Configuration.new
      @config.auto_configure! if active?
    end

    def configure(&block)
      @config.update(&block)
    end

    def active?
      return @active unless @active.nil?
      @active = (!ENV[ACTIVE_FLAG].nil? && ENV[ACTIVE_FLAG] =~ /0|false/i)
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
