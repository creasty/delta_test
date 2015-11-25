require_relative 'git'

module DeltaTest
  class Stats

    INDEX_DIR = 'indexes'

    def initialize
      @base_git  = Git.new(DeltaTest.config.base_path)
      @stats_git = Git.new(DeltaTest.config.stats_path)
    end

    def find_base_commit
      indexes = @stats_git.ls_files(path: INDEX_DIR)
        .map { |f| f.sub('/', '') }
        .to_set

      @base_git.ls_hashes(DeltaTest.config.stats_life)
        .find { |h| indexes.include?(h) }
    end

    def self.find_index_file_by_commit(commit)
      DeltaTest.config.stats_path.join(INDEX_DIR, *commit.unpack('A2A*'))
    end

  end
end
