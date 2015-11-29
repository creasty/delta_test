require 'fileutils'

require_relative 'command_base'
require_relative '../dependencies_table'
require_relative '../stats'

module DeltaTest
  class CLI
    class StatsSaveCommand < CommandBase

      def invoke!
        tmp_table_files.each do |tmp_table_file|
          tmp_table = DependenciesTable.load(tmp_table_file)
          table.reverse_merge!(tmp_table)
        end
        cleanup_tmp_table_files

        table.dump(stats.table_file_path)

        status = true
        status &&= stats.stats_git.add(stats.table_file_path)
        status &&= stats.stats_git.commit(stats.base_commit)

        if stats.stats_git.has_remote?
          status &&= stats.stats_git.pull
          status &&= stats.stats_git.push
        end

        raise StatsRepositorySyncError unless status
      end

      def tmp_table_files
        return @tmp_table_files if defined?(@tmp_table_files)
        tmp_table_files_pattern ||= DeltaTest.config.tmp_table_file.parent.join('*')
        @tmp_table_files = Dir.glob(tmp_table_files_pattern)
      end

      def cleanup_tmp_table_files
        FileUtils.rm_rf(DeltaTest.config.tmp_table_file.parent)
      end

      def table
        @table ||= DependenciesTable.new
      end

      def stats
        @stats ||= Stats.new(head: true)
      end

    end
  end
end
