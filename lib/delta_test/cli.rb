require 'open3'
require 'shellwords'
require 'thread'
require 'thwait'

require_relative 'related_spec_list'

module DeltaTest
  class CLI

    DEFAULTS = {
      'base'    => 'master',
      'head'    => 'HEAD',
      'verbose' => false,
    }.freeze

    BUNDLE_EXEC = ['bundle', 'exec'].freeze

    SPLITTER = '--'

    attr_reader *%i[
      args
      command
      options
    ]

    def initialize
      @args    = []
      @command = nil
      @options = {}
    end

    ###
    # Run cli
    #
    # @params {Array} args
    ###
    def run(args)
      @args = args.dup

      @command = @args.shift
      @options = parse_options!

      @list = RelatedSpecList.new

      DeltaTest.verbose = !!@options['verbose']

      invoke
    end

    ###
    # Invoke action method
    ###
    def invoke
      begin
        case @command
        when 'list'
          do_list
        when 'table'
          do_table
        when 'exec'
          do_exec
        when '-v', '--version'
          do_version
        else
          do_help
        end
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
    def parse_options!
      options = {}

      @args.reject! do |arg|
        case arg
        when /^-([a-z0-9])$/i, /^--([a-z0-9][a-z0-9-]*)$/i
          options[$1] = true
        when /^--([a-z0-9][a-z0-9-]*)=(.+)$/i
          options[$1] = $2
        else
          break
        end
      end

      DEFAULTS.merge(options)
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
    # Whether run full test or not
    #
    # @return {Boolean}
    ###
    def profile_mode?
      @profile_mode ||= Git.same_commit?(@options['base'], @options['head'])
    end

    ###
    # Show table contents
    ###
    def do_table
      @list.load_table!

      @list.table.each do |spec_file, dependencies|
        puts spec_file
        puts
        dependencies.each do |dependency|
          puts "\t#{dependency}"
        end
        puts
      end
    end

    ###
    # Show related spec files
    ###
    def do_list
      @list.load_table!
      @list.retrive_changed_files!(@options['base'], @options['head'])

      puts @list.related_spec_files
    end

    ###
    # Execute test script with delta_test
    ###
    def do_exec
      spec_files = nil
      args = []

      begin
        unless profile_mode?
          @list.load_table!
          @list.retrive_changed_files!(@options['base'], @options['head'])

          spec_files = @list.related_spec_files.to_a

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
      args = args.join(' ')

      $stdout.sync = true

      Open3.popen3(args) do |i, o, e, w|
        i.write(spec_files.join("\n")) if spec_files
        i.close

        threads = []
        threads << Thread.new { o.each { |l| puts l } }
        threads << Thread.new { e.each { |l| $stderr.puts l } }

        ThreadsWait.all_waits(*threads)
        exit w.value.exitstatus
      end
    end

    ###
    # Show version
    ###
    def do_version
      puts 'DeltaTest v%s' % VERSION
    end

    ###
    # Show help
    ###
    def do_help
      if !@command.nil? && '-' != @command[0]
        puts "Command not found: #{@command}"
      end

      puts <<HELP
usage: delta_test <command> [--base=<base>] [--head=<head>] [--verbose] [<args>]
                  [-v|--version]

options:
    --base=<base>  A branch or a commit id to diff from.
                   <head> is default to master.

    --head=<head>  A branch or a commit id to diff to.
                   <head> is default to HEAD. (current branch you're on)

    --verbose      Print more output.

    -v, --version  Show version.

commands:
    list           List related spec files for changes between base and head.
                   head is default to master; base is to the current branch.

    table          Show dependencies table.

    exec <script> [-- <files>]
                   Execute test script using delta_test.
                   if <base> and <head> is the same commit or no dependencies table is found,
                   it'll run full test cases with a profile mode to create a table.
                   Otherwise, it'll run test script with only related spec files
                   passed by its arguments, like `delta_test list | xargs script'.
HELP
    end


  private

    ###
    # Check bundler existance
    #
    # @see http://github.com/carlhuda/bundler Bundler::SharedHelpers#find_gemfile
    ###
    def bundler_enabled?
      return true if Object.const_defined?(:Bundler)

      previous = nil
      current = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return true if File.exist?(filename)
        current, previous = File.expand_path('..', current), current
      end

      false
    end

  end
end
