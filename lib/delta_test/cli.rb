require_relative 'cli/list_command'
require_relative 'cli/table_command'
require_relative 'cli/exec_command'
require_relative 'cli/save_command'
require_relative 'cli/version_command'
require_relative 'cli/help_command'


module DeltaTest
  class CLI

    def initialize(args)
      @args    = args.dup
      @command = @args.shift
    end

    COMMANDS = {
      'list'    => ListCommand,
      'table'   => TableCommand,
      'exec'    => ExecCommand,
      'save'    => SaveCommand,
      'version' => VersionCommand,
      'help'    => HelpCommand,
    }

    ###
    # Run cli
    ###
    def run
      command_class = COMMANDS[@command] || COMMANDS['help']
      command_class.new(@args).invoke
    end

  end
end
