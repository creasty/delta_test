require_relative 'command_base'

module DeltaTest
  class CLI
    class HelpCommand < CommandBase

      TEXT = <<HELP
usage: delta_test <command> [--verbose] [<args>]

options:
    --verbose      Print more output.

commands:
    exec [--force] <script> -- <files...>
                   Execute test script using delta_test.
                   --force to force DeltaTest to run full test in profile mode.

    specs          List related spec files for changes.

    stats:clean    Clean up temporary files.

    stats:show     Show dependencies table.

    stats:save [--no-sync]
                   Save and sync a table file.

    version        Show version.

    help           Show this.
HELP

      def invoke!
        puts TEXT
      end

    end
  end
end
