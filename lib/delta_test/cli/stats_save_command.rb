require 'fileutils'

require_relative 'command_base'
require_relative '../dependencies_table'
require_relative '../stats'

module DeltaTest
  class CLI
    class StatsSaveCommand < CommandBase

      def invoke!
        load_tmp_table_files
        cleanup_tmp_table_files
        save_table_file

        stage_table_file
        sync_table_file unless @options['no-sync']
      end

      def load_tmp_table_files
        tmp_table_files.each do |tmp_table_file|
          tmp_table = DependenciesTable.load(tmp_table_file)
          table.reverse_merge!(tmp_table)
        end
      end

      def cleanup_tmp_table_files
        tmp_dir = DeltaTest.config.tmp_table_file.parent
        FileUtils.rm_rf(tmp_dir) if File.directory?(tmp_dir)
      end

      def save_table_file
        table.dump(stats.table_file_path)
      end

      def stage_table_file
        status = true
        status &&= stats.stats_git.add(stats.table_file_path)
        status &&= stats.stats_git.commit(stats.base_commit)
        raise TableFileStageError unless status
      end

      def sync_table_file
        return unless stats.stats_git.has_remote?
        status = true
        status &&= stats.stats_git.pull
        status &&= stats.stats_git.push
        raise StatsRepositorySyncError unless status
      end

      def tmp_table_files
        return @tmp_table_files if defined?(@tmp_table_files)
        tmp_table_files_pattern ||= DeltaTest.config.tmp_table_file.parent.join('*')
        @tmp_table_files = Dir.glob(tmp_table_files_pattern)
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
