module DeltaTest
  class Profiler

    ###
    # Gather source files in the call stack
    #
    # @return {Set<String>}
    ###
    def related_source_files
      return nil if self.running?  # to avoid endless recursion

      Set.new(self.result)
    end

    def self.profile
      profile = new
      profile.start

      begin
        yield
      ensure
        profile.stop
      end

      profile.result
    end

  end
end
