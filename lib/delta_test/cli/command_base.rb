require 'fileutils'
require 'open3'
require 'shellwords'
require 'thread'
require 'thwait'

module DeltaTest
  class CLI
    class CommandBase

      DEFAULT_OPTIONS = {
        'verbose' => false,
        'force'   => false,
        'no-sync' => false,
      }.freeze

      attr_reader(*%i[
        args
        options
      ])

      def initialize(args)
        @args    = args.dup
        @options = parse_options!(@args)

        DeltaTest.verbose = !!@options['verbose']
      end

      def invoke!
        raise 'Not implemented'
      end

      def invoke
        begin
          invoke!
        rescue => e
          if DeltaTest.verbose?
            raise e
          else
            exit_with_message(1, '[%s] %s' % [e.class.name, e.message])
          end
        end
      end

      ###
      # Parse option arguments
      #
      # @return {Hash<String, Boolean|String>}
      ###
      def parse_options!(args)
        options = {}

        args.reject! do |arg|
          case arg
          when /^-([a-z0-9])$/i, /^--([a-z0-9][a-z0-9-]*)$/i
            options[$1] = true
          when /^--([a-z0-9][a-z0-9-]*)=(.+)$/i
            options[$1] = $2
          else
            break
          end
        end

        DEFAULT_OPTIONS.merge(options)
      end

      ###
      # Print message and exit with a status
      #
      # @params {Integer} status - exit code
      # @params {Object} *args
      ###
      def exit_with_message(status, *args)
        if status.zero?
          puts(*args)
        else
          $stderr.puts(*args)
        end

        exit status
      end

      ###
      # Exec command with data passed as stdin
      #
      # @params {String} args
      # @params {Array} ary
      # @params {Integer|Nil} status
      ###
      def exec_with_data(args, ary, status = nil)
        $stdout.sync = true

        Open3.popen3(args) do |i, o, e, w|
          i.write(ary.join("\n")) if ary
          i.close

          threads = []
          threads << Thread.new { o.each { |l| puts l } }
          threads << Thread.new { e.each { |l| $stderr.puts l } }

          ThreadsWait.all_waits(*threads)
          exit(status.nil? ? w.value.exitstatus : status)
        end
      end

      ###
      # Check bundler existance
      #
      # @return {Boolean}
      ###
      def bundler_enabled?
        Object.const_defined?(:Bundler) || !!Utils.find_file_upward('Gemfile')
      end

      ###
      # Wrapper of hook_create_error_file
      #
      # @block
      ###
      def record_error
        hook_create_error_file
        yield if block_given?
      end

      ###
      # Hook on exit and record errors
      ###
      def hook_create_error_file
        at_exit do
          next if $!.nil? || $!.is_a?(SystemExit) && $!.success?
          create_error_file
        end
      end

      ###
      # Check if any error is recorded
      #
      # @return {Boolean}
      ###
      def error_recorded?
        File.exists?(error_file)
      end

      ###
      # Path for an error file
      #
      # @return {Pathname}
      ###
      def error_file
        @error_file ||= DeltaTest.config.tmp_table_file.parent.join('error.txt')
      end

      ###
      # Create an error file
      ###
      def create_error_file
        FileUtils.mkdir_p(File.dirname(error_file))
        File.new(error_file, 'w')
      end

    end
  end
end
