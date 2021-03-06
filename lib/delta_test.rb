require_relative 'delta_test/version'
require_relative 'delta_test/errors'
require_relative 'delta_test/configuration'

# Load the C binding
begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require_relative "#{$1}/delta_test_native"
rescue LoadError
  require_relative 'delta_test_native'
end

module DeltaTest

  ACTIVE_FLAG  = 'DELTA_TEST_ACTIVE'
  VERBOSE_FLAG = 'DELTA_TEST_VERBOSE'

  class << self

    attr_reader :config

    attr_writer(*%i[
      active
      verbose
    ])

    def config
      @config ||= Configuration.new.tap do |c|
        c.auto_configure! if active?
      end
    end

    def configure(&block)
      config.update(&block)
    end

    def active?
      return !!@active unless @active.nil?
      @active = (!ENV[ACTIVE_FLAG].nil? && ENV[ACTIVE_FLAG] !~ /0|false/i)
    end

    def verbose?
      return !!@verbose unless @verbose.nil?
      @verbose = (!ENV[VERBOSE_FLAG].nil? && ENV[VERBOSE_FLAG] !~ /0|false/i)
    end

    def log(*args)
      puts(*args) if verbose?
    end

    def tester_id
      return @tester_id if @tester_id
      t = Time.now
      @tester_id = '%d-%d-%d' % [t.to_i, t.nsec, $$]
    end

  end
end
