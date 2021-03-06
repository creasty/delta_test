require 'open3'
require 'shellwords'

module DeltaTest
  class Git

    attr_reader :dir

    def initialize(dir)
      @dir = Pathname.new(dir)
    end

    ###
    # Check if in git managed directory
    #
    # @return {Boolean}
    ###
    def git_repo?
      _, _, s = exec(%q{rev-parse --is-inside-work-tree}) rescue []
      !!s && s.success?
    end

    ###
    # Get root directory of git
    #
    # @return {String}
    ###
    def root_dir
      o, _, s = exec(%q{rev-parse --show-toplevel})
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
      o, _, s = exec(%q{rev-parse %s}, rev)
      s.success? ? o.strip : nil
    end

    ###
    # Get name of the current branch
    #
    # @return {String}
    ###
    def current_branch
      o, _, s = exec(%q{symbolic-ref --short HEAD})
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
    def ls_files(path: '.')
      o, _, s = exec(%q{ls-files -z %s}, path)
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
    def changed_files(base = 'master', head = 'HEAD', path: '.')
      o, _, s = exec(%q{diff --name-only -z %s %s %s}, base, head, path)
      s.success? ? o.split("\x0") : []
    end

    ###
    # Get list of hashes for the last N commits
    #
    # @params {Integer} n
    #
    # @return {Array<String>}
    ###
    def ls_hashes(n)
      o, _, s = exec(%q{log -z -n %d --format='%%H'}, n.to_i)
      s.success? ? o.split("\x0") : []
    end

    ###
    # Get url for the remote origin
    #
    # @return {String}
    ###
    def remote_url
      o, _, s = exec(%q{config --get remote.origin.url})
      s.success? ? o.strip : nil
    end

    ###
    # Check if it has a remote origin
    #
    # @return {String}
    ###
    def has_remote?
      !!remote_url rescue false
    end

    ###
    # Pull from the origin master
    #
    # @return {Boolean}
    ###
    def pull
      _, _, s = exec(%q{pull origin master})
      s.success?
    end

    ###
    # Push to the origin master
    #
    # @return {Boolean}
    ###
    def push
      _, _, s = exec(%q{push origin master})
      s.success?
    end

    ###
    # Add a path to the index
    #
    # @return {Boolean}
    ###
    def add(path)
      _, _, s = exec(%q{add %s}, path.to_s)
      s.success?
    end

    ###
    # Create commit
    #
    # @return {Boolean}
    ###
    def commit(message)
      _, _, s = exec(%q{commit -m %s}, message.to_s)
      s.success?
    end

    ###
    # Util for executing command
    ###
    def exec(subcommand, *args)
      command = [
        'git',
        '--git-dir=%s',
        '--no-pager',
        subcommand,
      ].join(' ')

      args.unshift(@dir.join('.git'))
      args.map! { |a| a.is_a?(String) ? Shellwords.escape(a) : a }

      Open3.capture3(command % args, chdir: @dir)
    end

  end
end
