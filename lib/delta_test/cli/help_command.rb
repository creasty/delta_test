require_relative 'command_base'

module DeltaTest
  class CLI
    class HelpCommand < CommandBase

      TEXT = <<HELP
usage: delta_test <command> [--verbose] [<args>]

options:
--verbose      Print more output.

commands:
list           List related spec files for changes.

table          Show dependencies table.

exec [--force-run] <script> -- <files...>
               Execute test script using delta_test.
               --force-run to force DeltaTest to run full test cases.

save           Clean up tables and caches.

version        Show version.

help           Show this.
HELP

      def invoke!
        puts TEXT
      end

    end
  end
end
