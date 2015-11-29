require_relative 'git'

module DeltaTest
  class Stats

    attr_reader :base_git
    attr_reader :stats_git

    TABLE_FILENAME = 'table.marshal'

    def initialize
      @base_git  = Git.new(DeltaTest.config.base_path)
      @stats_git = Git.new(DeltaTest.config.stats_path)
    end

    def base_commit
      return @base_commit if defined?(@base_commit)

      indexes = @stats_git.ls_files
        .map { |f| f.sub('/', '') }
        .to_set

      @base_commit = @base_git.ls_hashes(DeltaTest.config.stats_life)
        .find { |h| indexes.include?(h) }
    end

    def commit_dir
      return unless base_commit
      return @commit_dir if defined?(@commit_dir)

      @commit_dir = DeltaTest.config.stats_path.join(*base_commit.unpack('A2A*'))
    end

    def table_file_path
      commit_dir && commit_dir.join(TABLE_FILENAME)
    end

  end
end
