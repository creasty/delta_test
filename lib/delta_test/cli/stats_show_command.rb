require_relative 'command_base'
require_relative '../stats'
require_relative '../dependencies_table'

module DeltaTest
  class CLI
    class StatsShowCommand < CommandBase

      def invoke!
        @stats = Stats.new

        if @stats.base_commit
          puts 'Base commit: %s' % [@stats.base_commit]
          puts
        else
          raise StatsNotFoundError
        end

        @table = DependenciesTable.load(@stats.table_file_path)
        print_table
      end

      def print_table
        @table.each do |spec_file, dependencies|
          puts spec_file
          puts
          dependencies.each do |dependency|
            puts "\t#{dependency}"
          end
          puts
        end
      end

    end
  end
end
