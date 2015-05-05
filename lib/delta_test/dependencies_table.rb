require "fileutils"

require_relative "dependencies"

module DeltaTest
  class DependenciesTable < ::Hash

    def initialize(klass = Set)
      super

      @klass = klass
      self.default_proc = -> (h, k) do
        h[k] = @klass.new
      end
    end

    def self.load(file, klass = Set)
      begin
        data = File.binread(file)
        Marshal.load(data)
      rescue
        self.new(klass)
      end
    end

    def without_default_proc
      _default_proc = self.default_proc
      self.default_proc = nil

      begin
        yield
      ensure
        self.default_proc = _default_proc
      end
    end

    def cleanup!
      self.reject! do |k, v|
        v.empty?
      end
    end

    def dump(file)
      # Marshal can't dump hash with default proc
      without_default_proc do
        cleanup!
        data = Marshal.dump(self)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, "wb") { |f| f.write data }
      end
    end

  end
end
