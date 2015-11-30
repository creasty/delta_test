require_relative 'command_base'
require_relative '../stats'
require_relative '../related_spec_list'

module DeltaTest
  class CLI
    class ExecCommand < CommandBase

      BUNDLE_EXEC = ['bundle', 'exec'].map(&:freeze).freeze
      SPLITTER    = '--'.freeze

      def invoke!
        retrive_spec_files
        extract_arg_files
        filter_spec_files
        run_command
      end

      def stats
        @stats ||= Stats.new
      end

      def list
        @list ||= RelatedSpecList.new
      end

      def profile_mode?
        return @profile_mode if defined?(@profile_mode)
        @profile_mode = !stats.base_commit || !!@options['force']
      end

      def retrive_spec_files
        return if profile_mode?

        puts 'Base commit: %s' % [stats.base_commit]
        puts

        list.load_table!(stats.table_file_path)
        list.retrive_changed_files!(stats.base_commit)

        @spec_files = list.related_spec_files.to_a

        if @spec_files.empty?
          exit_with_message(0, 'Nothing to test')
        end
      rescue TableNotFoundError
        # force profile mode cuz we don't have a table
        @profile_mode = true
      end

      def extract_arg_files
        @args.map! { |arg| Shellwords.escape(arg) }

        splitter = @args.index(SPLITTER)
        return unless splitter

        @arg_files = @args.drop(splitter + 1)
        if @arg_files && @arg_files.any?
          @args = @args.take(splitter)
        else
          @arg_files = nil
        end
      end

      def filter_spec_files
        return unless @arg_files

        if @spec_files
          pattern = @arg_files.map { |file| Regexp.escape(file) }
          pattern = '^(%s)' % pattern.join('|')
          @spec_files = @spec_files.grep(pattern)
        else
          @spec_files = @arg_files
        end
      end

      def run_command
        args = []

        if profile_mode?
          args << ('%s=%s' % [VERBOSE_FLAG, true]) if DeltaTest.verbose?
          args << ('%s=%s' % [ACTIVE_FLAG, true])
        end

        if @spec_files
          args.unshift('cat', '|')
          args << 'xargs'
        end

        if bundler_enabled? && BUNDLE_EXEC != @args.take(2)
          args += BUNDLE_EXEC
        end

        args += @args

        exec_with_data(args.join(' '), @spec_files)
      end

    end
  end
end
