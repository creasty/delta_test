require 'pathname'

require_relative 'delta_test/version'
require_relative 'delta_test/errors'
require_relative 'delta_test/configuration'

module DeltaTest

  ACTIVE_FLAG  = 'DELTA_TEST_ACTIVE'
  VERBOSE_FLAG = 'DELTA_TEST_VERBOSE'

  class << self

    attr_reader :config
    attr_writer :verbose

    def setup
      @config = Configuration.new
      @config.auto_configure! if active?
    end

    def configure(&block)
      @config.update(&block)
    end

    def active?
      return @active unless @active.nil?
      @active = (!ENV[ACTIVE_FLAG].nil? && ENV[ACTIVE_FLAG] !~ /0|false/i)
    end

    def activate!
      @active = true
    end

    def deactivate!
      @active = false
    end

    def verbose?
      return @verbose unless @verbose.nil?
      @verbose = (!ENV[VERBOSE_FLAG].nil? && ENV[VERBOSE_FLAG] !~ /0|false/i)
    end

    def log(*args)
      puts *args if verbose?
    end

  end
end

DeltaTest.setup
