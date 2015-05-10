require 'fileutils'
require 'set'

require_relative 'utils'

module DeltaTest
  class DependenciesTable < ::Hash

    DEFAULT_PROC = -> (h, k) { h[k] = ::Set.new }

    def initialize
      super

      self.default_proc = DEFAULT_PROC
    end

    ###
    # Restore a table object from a file
    #
    # @params {String|Pathname} file
    ###
    def self.load(file)
      begin
        data = File.binread(file)
        dt = Marshal.load(data)
        dt.default_proc = DEFAULT_PROC
        dt
      rescue
        self.new
      end
    end

    ###
    # Add a dependency for a spec file
    #
    # @params {String} spec_file
    # @params {String} source_file
    ###
    def add(spec_file, source_file)
      source_file = Utils.regulate_filepath(source_file, DeltaTest.config.base_path)
      self[spec_file] << source_file if DeltaTest.config.filtered_files.include?(source_file)
    end

    ###
    # Temporary disable default_proc
    # Because Marshal can't dump Hash with default_proc
    #
    # @block
    ###
    def without_default_proc
      self.default_proc = nil

      begin
        yield
      ensure
        self.default_proc = DEFAULT_PROC
      end
    end

    ###
    # Cleanup empty sets from the table
    ###
    def cleanup!
      self.reject! { |k, v| v.empty? }
    end

    ###
    # Dump the table object to a file
    #
    # @params {String|Pathname} file
    ###
    def dump(file)
      # Marshal can't dump hash with default proc
      without_default_proc do
        cleanup!
        data = Marshal.dump(self)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'wb') { |f| f.write data }
      end
    end

  end
end
