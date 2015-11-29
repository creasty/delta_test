require_relative 'git'

module DeltaTest
  class Stats

    attr_reader :base_git
    attr_reader :stats_git

    def initialize
      @base_git  = Git.new(DeltaTest.config.base_path)
      @stats_git = Git.new(DeltaTest.config.stats_path)
    end

    def find_base_commit
      indexes = @stats_git.ls_files
        .map { |f| f.sub('/', '') }
        .to_set

      @base_git.ls_hashes(DeltaTest.config.stats_life)
        .find { |h| indexes.include?(h) }
    end

    def find_commit_dir
      _base_commit_dir = find_base_commit
      return unless _base_commit_dir
      self.class.find_commit_dir(_base_commit_dir)
    end

    def self.find_commit_dir(commit)
      DeltaTest.config.stats_path.join(*commit.unpack('A2A*'))
    end

  end
end
