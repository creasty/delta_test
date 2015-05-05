require "open3"
require "shellwords"

module DeltaTest
  module Git
    class << self

      def git_repo?
        o, e, s = Open3.capture3(%q{git rev-parse --is-inside-work-tree}) rescue []
        s && s.success?
      end

      def root_dir
        o, e, s = Open3.capture3(%q{git rev-parse --show-toplevel})
        o
      end

      def ls_files
        o, e, s = Open3.capture3(%q{git ls-files})
        o
      end

    end
  end
end
