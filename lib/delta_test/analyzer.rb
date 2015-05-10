require 'ruby-prof'

module DeltaTest
  class Analyzer

    attr_reader :result

    ###
    # Start analyzer
    ###
    def start
      @result = nil
      @files  = Set.new

      RubyProf.stop if RubyProf.running?
      RubyProf.start
    end

    ###
    # Stop analyzer
    ###
    def stop
      @result = nil
      @result = RubyProf.stop if RubyProf.running?
    end

    ###
    # Gather source files in the call stack
    #
    # @return {Set<String>}
    ###
    def related_source_files
      return @files unless @result

      @result.threads.each do |thread|
        thread.methods.each do |method|
          @files << method.source_file
        end
      end

      @result = nil

      @files
    end

  end
end
