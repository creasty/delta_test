require 'open3'
require 'shellwords'

require_relative 'related_spec_list'

module DeltaTest
  class CLI

    DEFAULTS = {
      'base' => 'master',
      'head' => 'HEAD',
    }.freeze

    attr_reader *%i[
      bin
      args
      options
      command
    ]

    def run(bin, args)
      @bin, @args = bin, args

      @command = @args.shift
      @options = parse_options!

      begin
        case @command
        when 'list'
          do_list
        when 'table'
          do_show_table
        when 'exec'
          do_exec
        else
          do_help(@command)
        end
      rescue TableNotFoundError, NotInGitRepository => e
        exit_with_message(1, '[%s] %s' % [e.class.name, e.message])
      end
    end

    def parse_options!
      options = {}

      @args.reject! do |arg|
        case arg
        when /^-[a-z0-9]$/, /^--([a-z0-9]\w*)$/
          options[$1] = true
        when /^--([a-z0-9]\w*)=(.+)$/
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

    def do_show_table
      list = RelatedSpecList.new
      list.load_table!

      list.table.each do |spec_file, dependencies|
        puts spec_file
        puts
        dependencies.each do |dependency|
          puts "\t#{dependency}"
        end
      end
    end

    def do_list
      list = RelatedSpecList.new
      list.load_table!
      list.retrive_changed_files!(@options['base'], @options['head'])

      puts list.related_spec_files
    end

    def do_exec
      args = []
      args << 'cat'
      args << '|'
      args << ('%s=%s' % [ACTIVE_FLAG, true])
      args << 'xargs'
      args += @args
      args = args.join(' ')

      list = RelatedSpecList.new
      list.load_table!
      list.retrive_changed_files!(@options['base'], @options['head'])

      if list.related_spec_files.empty?
        exit_with_message(0, 'Nothing to test')
      end

      Open3.popen3(args) do |i, o, e, w|
        i.write(list.related_spec_files.to_a.join("\n"))
        i.close
        o.each { |l| puts l }
        e.each { |l| $stderr.puts l }
      end
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
