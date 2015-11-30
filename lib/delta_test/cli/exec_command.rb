require_relative 'command_base'
require_relative '../stats'
require_relative '../related_spec_list'

module DeltaTest
  class CLI
    class ExecCommand < CommandBase

      BUNDLE_EXEC = ['bundle', 'exec'].map(&:freeze).freeze
      SPLITTER    = '--'.freeze

      def invoke!
        if stats.base_commit
          puts 'Base commit: %s' % [stats.base_commit]
          puts
        end

        spec_files = nil
        args = []

        begin
          unless profile_mode?
            list.load_table!(stats.table_file_path)
            list.retrive_changed_files!(stats.base_commit)

            spec_files = list.related_spec_files.to_a

            if spec_files.empty?
              exit_with_message(0, 'Nothing to test')
            end
          end
        rescue TableNotFoundError
          # force profile mode cuz we don't have a table
          @profile_mode = true
        end

        @args.map! { |arg| Shellwords.escape(arg) }

        if (splitter = @args.index(SPLITTER))
          files = @args.drop(splitter + 1)
          @args = @args.take(splitter)

          if files && files.any?
            if spec_files
              pattern = files.map { |file| Regexp.escape(file) }
              pattern = '^(%s)' % pattern.join('|')
              spec_files = spec_files.grep(pattern)
            else
              spec_files = files
            end
          end
        end

        if profile_mode?
          args << ('%s=%s' % [VERBOSE_FLAG, true]) if DeltaTest.verbose?
          args << ('%s=%s' % [ACTIVE_FLAG, true])
        end

        if spec_files
          args.unshift('cat', '|')
          args << 'xargs'
        end

        if bundler_enabled? && BUNDLE_EXEC != @args.take(2)
          args += BUNDLE_EXEC
        end

        args += @args

        $stdout.sync = true

        exec_with_data(args.join(' '), spec_files)
      end

      def stats
        @stats ||= Stats.new
      end

      def list
        @list ||= RelatedSpecList.new
      end

      ###
      # Whether run full test or not
      #
      # @return {Boolean}
      ###
      def profile_mode?
        return @profile_mode if defined?(@profile_mode)
        @profile_mode = !stats.base_commit && !!@options['force-run']
      end

    end
  end
end
