require_relative 'cli/exec_command'
require_relative 'cli/specs_command'
require_relative 'cli/stats_fetch_command'
require_relative 'cli/stats_show_command'
require_relative 'cli/stats_save_command'
require_relative 'cli/version_command'
require_relative 'cli/help_command'


module DeltaTest
  class CLI

    def initialize(args)
      @args    = args.dup
      @command = @args.shift
    end

    COMMANDS = {
      'exec'        => ExecCommand,
      'specs'       => SpecsCommand,
      'stats:fetch' => StatsFetchCommand,
      'stats:show'  => StatsShowCommand,
      'stats:save'  => StatsSaveCommand,
      'version'     => VersionCommand,
      'help'        => HelpCommand,
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
