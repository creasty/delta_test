require_relative "git"
require_relative "dependencies_table"

module DeltaTest
  class RelatedSpecList

    attr_reader *%i[
      table
      changed_files
    ]

    def initialize(base, head)
      @base, @head = base, head
    end

    def load_table!
      unless File.exist?(DeltaTest.config.table_file_path)
        raise TableNotFoundError.new("table file not found at: `%s`" % DeltaTest.config.table_file_path)
      end

      @table = DependenciesTable.load(DeltaTest.config.table_file_path)
    end

    def retrive_changed_files!
      unless Git.git_repo?
        raise NotInGitRepository.new("the directory is not managed by git")
      end

      @changed_files = Git.changed_files(@base, @head)
    end

  end
end
