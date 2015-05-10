require 'open3'
require 'shellwords'

require_relative 'related_spec_list'

module DeltaTest
  class CLI

    DEFAULTS = {
      'base'    => 'master',
      'head'    => 'HEAD',
      'verbose' => false,
    }.freeze

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

    def run(args)
      @args = args.dup

      @command = @args.shift
      @options = parse_options!

      @list = RelatedSpecList.new

      DeltaTest.verbose = !!@options['verbose']

      invoke
    end

    def invoke
      begin
        case @command
        when 'list'
          do_list
        when 'table'
          do_table
        when 'exec'
          do_exec
        when '-v'
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

    def exit_with_message(status, *args)
      if status.zero?
        puts(*args)
      else
        $stderr.puts(*args)
      end

      exit status
    end

    def run_full_tests?
      Git.same_commit?(@options['base'], @options['head'])
    end

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

    def do_list
      @list.load_table!
      @list.retrive_changed_files!(@options['base'], @options['head'])

      puts @list.related_spec_files
    end

    def do_exec
      spec_files = nil
      args = []

      if run_full_tests?
        args << ('%s=%s' % [VERBOSE_FLAG, true]) if DeltaTest.verbose?
        args << ('%s=%s' % [ACTIVE_FLAG, true])
      else
        args << 'cat'
        args << '|'
        args << 'xargs'

        @list.load_table!
        @list.retrive_changed_files!(@options['base'], @options['head'])

        spec_files = @list.related_spec_files.to_a

        if spec_files.empty?
          exit_with_message(0, 'Nothing to test')
        end
      end

      args += @args
      args = args.join(' ')

      $stdout.sync = true

      Open3.popen3(args) do |i, o, e, w|
        i.write(spec_files.join("\n")) if spec_files
        i.close
        o.each { |l| puts l }
        e.each { |l| $stderr.puts l }
      end
    end

    def do_version
      puts 'DeltaTest v%s' % VERSION
    end

    def do_help
      if !@command.nil? && '-' != @command[0]
        puts "Command not found: #{@command}"
      end

      puts <<-HELP
usage: delta_test <command>

Commands:

list <base> <head>
    List related spec files for changes between base and head.
    head is default to master; base is to the current branch.

table
    Show dependencies table.

exec <base> <head> <script...>
    Execute test script for only related files.
    Run `delta_test list | xargs script...`.
      HELP
    end

  end
end
