require 'open3'
require 'shellwords'

module DeltaTest
  module Git
    class << self

      def git_repo?
        o, e, s = Open3.capture3(%q{git rev-parse --is-inside-work-tree}) rescue []
        !!s && s.success?
      end

      def root_dir
        o, e, s = Open3.capture3(%q{git rev-parse --show-toplevel})
        s.success? ? o.strip : nil
      end

      def ls_files
        o, e, s = Open3.capture3(%q{git ls-files -z})
        s.success? ? o.split("\x0") : []
      end

      def changed_files(base = 'master', head = 'HEAD')
        args = [base, head].map { |a| Shellwords.escape(a) }
        o, e, s = Open3.capture3(%q{git --no-pager diff --name-only -z %s %s} % args)
        s.success? ? o.split("\x0") : []
      end

    end
  end
end
