require 'set'

require_relative 'git'
require_relative 'dependencies_table'

module DeltaTest
  class RelatedSpecList

    attr_reader *%i[
      table
      changed_files
    ]

    def load_table!
      unless File.exist?(DeltaTest.config.table_file_path)
        raise TableNotFoundError.new(DeltaTest.config.table_file_path)
      end

      @table = DependenciesTable.load(DeltaTest.config.table_file_path)
    end

    def retrive_changed_files!(base, head)
      unless Git.git_repo?
        raise NotInGitRepositoryError
      end

      @changed_files = Git.changed_files(base, head)
    end

    def related_spec_files
      spec_files = Set.new

      @table.each do |spec_file, dependencies|
        related = @changed_files.include?(spec_file) \
          || (dependencies & @changed_files).any?

        spec_files << spec_file if related
      end

      spec_files
    end

  end
end
