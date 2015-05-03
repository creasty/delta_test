require 'ruby-prof'

module DeltaTest
  class Analyzer

    def initializer
      @result = nil
      @files  = Set.new
    end

    def start
      RubyProf.stop if RubyProf.running?
      RubyProf.start
    end

    def stop
      @result = RubyProf.stop
    end

    def profile(&block)
      @result = RubyProf.profile(&block)
    end

    def related_source_files
      return @files unless @result

      @result.threads.each do |thread|
        thread.methods.each do |method|
         @files |= method.source_file
        end
      end

      @result = nil

      @files
    end

  end
end
