require_relative 'command_base'
require_relative '../stats'
require_relative '../related_spec_list'

module DeltaTest
  class CLI
    class SpecsCommand < CommandBase

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
        @list.retrive_changed_files!(@stats.base_commit)

        print_specs
      end

      def print_specs
        files = @list.related_spec_files.to_a

        if files.any?
          puts files
        else
          puts '(no spec files to run)'
        end
      end

    end
  end
end
