require 'open3'
require 'shellwords'

require_relative 'related_spec_list'

module DeltaTest
  class CLI

    def run(bin, args)
      @bin, @args = bin, args

      command = @args.shift

      begin
        case command
        when 'list'
          do_list(@args[0], @args[1])
        when 'table'
          do_show_table
        when 'exec'
          do_exec(@args[0], @args[1], @args[2..-1])
        else
          do_help(command)
        end
      rescue TableNotFoundError, NotInGitRepository => e
        STDERR.puts '[%s] %s' % [e.class.name, e.message]
        exit 1
      end
    end

    def do_show_table
      list = RelatedSpecList.new(nil, nil)
      list.load_table!
      p list.table if list
    end

    def do_list(base, head)
      list = RelatedSpecList.new(base, head)
      list.load_table!
      list.retrive_changed_files!
      puts list.related_spec_files if list
    end

    def do_exec(base, head, script)
      args = [base, head].map { |a| Shellwords.escape(a) }
      args << script
      # TODO
      # o, e, s = Open3.capture3()
      # s.success?
    end

    def do_help(command)
      if !command.nil? && '-' != command[0]
        puts "Command not found: #{command}"
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
