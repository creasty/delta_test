require 'open3'
require 'shellwords'

module DeltaTest
  module Git
    class << self

      def git_repo?
        o, e, s = exec(%q{git rev-parse --is-inside-work-tree}) rescue []
        !!s && s.success?
      end

      def root_dir
        o, e, s = exec(%q{git rev-parse --show-toplevel})
        s.success? ? o.strip : nil
      end

      def rev_parse(rev)
        o, e, s = exec(%q{git rev-parse %s}, rev)
        s.success? ? o.strip : nil
      end

      def same_commit?(r1, r2)
        rev_parse(r1) == rev_parse(r2)
      end

      def ls_files
        o, e, s = exec(%q{git ls-files -z})
        s.success? ? o.split("\x0") : []
      end

      def changed_files(base = 'master', head = 'HEAD')
        o, e, s = exec(%q{git --no-pager diff --name-only -z %s %s}, base, head)
        s.success? ? o.split("\x0") : []
      end


    private

      def exec(command, *args)
        args = args.map { |a| Shellwords.escape(a) }
        Open3.capture3(command % args, chdir: DeltaTest.config.base_path)
      end

    end
  end
end
