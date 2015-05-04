module DeltaTest
  class DependenciesTable < Hash

    def initialize
      super

      self.default_proc = -> (h, k) do
        h[k] = Set.new
      end
    end

    def self.load(file)
      data = File.binread(file)
      Marshal.load(data) rescue self.new
    end

    def dump(file)
      # can't dump hash with default proc
      _default_proc = self.default_proc
      self.default_proc = nil

      begin
        data = Marshal.dump(self)
        File.open(file, "wb") { |f| f.write data }
      ensure
        self.default_proc = _default_proc
      end
    end

  end
end
