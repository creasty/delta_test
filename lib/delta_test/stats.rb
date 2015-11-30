require_relative 'git'

module DeltaTest
  class Stats

    attr_reader :base_git
    attr_reader :stats_git

    TABLE_FILENAME_TPL     = '%s.table'.freeze
    TABLE_FILENAME_PATTERN = '*.table'.freeze

    def initialize(head: false)
      @head = !!head

      @base_git  = Git.new(DeltaTest.config.base_path)
      @stats_git = Git.new(DeltaTest.config.stats_path)
    end

    def base_commit
      return @base_commit if defined?(@base_commit)

      if @head
        @base_commit = @base_git.rev_parse('HEAD')
      else
        indexes = @stats_git.ls_files
          .map { |f| f.split('/').take(2).join('') }
          .to_set

        @base_commit = @base_git.ls_hashes(DeltaTest.config.stats_life)
          .find { |h| indexes.include?(h) }
      end

      @base_commit
    end

    def commit_dir
      return unless base_commit
      return @commit_dir if defined?(@commit_dir)

      @commit_dir = DeltaTest.config.stats_path.join(*base_commit.unpack('A2A*'))
    end

    def table_file_path
      return unless commit_dir

      if @head
        commit_dir.join(TABLE_FILENAME_TPL % [DeltaTest.tester_id])
      else
        file = Dir.glob(commit_dir.join(TABLE_FILENAME_PATTERN)).max do |f|
          File.basename(f).split('-').take(2).join('.').to_f
        end
        return unless file
        Pathname.new(file)
      end
    end

  end
end
