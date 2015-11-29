require_relative 'command_base'

module DeltaTest
  class CLI
    class HelpCommand < CommandBase

      TEXT = <<HELP
usage: delta_test <command> [--verbose] [<args>]

options:
--verbose      Print more output.

commands:
exec [--force-run] <script> -- <files...>
               Execute test script using delta_test.
               --force-run to force DeltaTest to run full test cases.

specs          List related spec files for changes.


stats:show     Show dependencies table.

stats:save [--no-sync]
               Clean up tables and caches.

version        Show version.

help           Show this.
HELP

      def invoke!
        puts TEXT
      end

    end
  end
end
