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

    def add(spec_file, source_file)
      source_file = Utils.regulate_filepath(source_file, DeltaTest.config.base_path)
      self[spec_file] << source_file if DeltaTest.config.filtered_files.include?(source_file)
    end

    def without_default_proc
      self.default_proc = nil

      begin
        yield
      ensure
        self.default_proc = DEFAULT_PROC
      end
    end

    def cleanup!
      self.reject! { |k, v| v.empty? }
    end

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
