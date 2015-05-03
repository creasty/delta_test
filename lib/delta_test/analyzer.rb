require "ruby-prof"

module DeltaTest
  class Analyzer

    attr_reader :result

    def start
      @result = nil
      @files  = Set.new

      RubyProf.stop if RubyProf.running?
      RubyProf.start
    end

    def stop
      raise unless RubyProf.running?
      @result = RubyProf.stop
    end

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
