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

  end
end
