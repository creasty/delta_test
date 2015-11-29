require_relative 'command_base'
require_relative '../stats'
require_relative '../related_spec_list'

module DeltaTest
  class CLI
    class StatsShowCommand < CommandBase

      def invoke!
        @stats = Stats.new
        @list  = RelatedSpecList.new

        if @stats.base_commit
          puts 'Base commit: %s' % [@stats.base_commit]
          puts
        else
          raise StatsNotFoundError
        end

        @list.load_table!(@stats.table_file_path)
        print_table
      end

      def print_table
        if @list.table.any?
          @list.table.each do |spec_file, dependencies|
            puts spec_file
            puts
            dependencies.each do |dependency|
              puts "\t#{dependency}"
            end
            puts
          end
        else
          puts '(no entry)'
        end
      end

    end
  end
end
