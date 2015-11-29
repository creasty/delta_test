require 'fileutils'

require_relative 'command_base'

module DeltaTest
  class CLI
    class StatsCleanCommand < CommandBase

      def invoke!
        cleanup_tmp_table_files
      end

      def cleanup_tmp_table_files
        tmp_dir = DeltaTest.config.tmp_table_file.parent
        FileUtils.rm_rf(tmp_dir) if File.directory?(tmp_dir)
      end

    end
  end
end
