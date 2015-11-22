require 'open3'
require 'shellwords'

module DeltaTest
  class Git

    attr_reader :dir

    def initialize(dir = nil)
      @dir = dir || DeltaTest.config.base_path
    end

    ###
    # Check if in git managed directory
    #
    # @return {Boolean}
    ###
    def git_repo?
      _, _, s = exec(%q{git rev-parse --is-inside-work-tree}) rescue []
      !!s && s.success?
    end

    ###
    # Get root directory of git
    #
    # @return {String}
    ###
    def root_dir
      o, _, s = exec(%q{git rev-parse --show-toplevel})
      s.success? ? o.strip : nil
    end

    ###
    # Get commit id from rev name
    #
    # @params {String} rev - e.g., branch name
    #
    # @return {String}
    ###
    def rev_parse(rev)
      o, _, s = exec(%q{git rev-parse %s}, rev)
      s.success? ? o.strip : nil
    end

    ###
    # Compare two rev names by their commit ids
    #
    # @params {String} r1
    # @params {String} r2
    #
    # @return {Boolean}
    ###
    def same_commit?(r1, r2)
      rev_parse(r1) == rev_parse(r2)
    end

    ###
    # Get file list from git index
    #
    # @return {Array<String>}
    ###
    def ls_files
      o, _, s = exec(%q{git ls-files -z})
      s.success? ? o.split("\x0") : []
    end

    ###
    # Get list of modified files in diff
    #
    # @params {String} base
    # @params {String} head
    #
    # @return {Array<String>}
    ###
    def changed_files(base = 'master', head = 'HEAD')
      o, _, s = exec(%q{git --no-pager diff --name-only -z %s %s}, base, head)
      s.success? ? o.split("\x0") : []
    end


  private

    ###
    # Util for executing command
    ###
    def exec(command, *args)
      args = args.map { |a| Shellwords.escape(a) }
      Open3.capture3(command % args, chdir: @dir)
    end

  end
end
