require_relative 'command_base'

module DeltaTest
  class CLI
    class VersionCommand < CommandBase

      def invoke!
        puts 'DeltaTest v%s' % VERSION
      end

    end
  end
end
