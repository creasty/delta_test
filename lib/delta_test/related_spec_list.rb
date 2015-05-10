require 'set'

require_relative 'git'
require_relative 'dependencies_table'

module DeltaTest
  class RelatedSpecList

    attr_reader *%i[
      table
      changed_files
    ]

    ###
    # Load table from the file
    ###
    def load_table!
      unless File.exist?(DeltaTest.config.table_file_path)
        raise TableNotFoundError.new(DeltaTest.config.table_file_path)
      end

      @table = DependenciesTable.load(DeltaTest.config.table_file_path)
    end

    ###
    # Retrive changed files in git diff
    #
    # @params {String} base
    # @params {String} head
    ###
    def retrive_changed_files!(base, head)
      unless Git.git_repo?
        raise NotInGitRepositoryError
      end

      @changed_files = Git.changed_files(base, head)
    end

    ###
    # Calculate related spec files
    #
    # @return {Set<String>}
    ###
    def related_spec_files
      spec_files = Set.new

      @table.each do |spec_file, dependencies|
        related = @changed_files.include?(spec_file) \
          || (dependencies & @changed_files).any?

        spec_files << spec_file if related
      end

      DeltaTest.config.custom_mappings.each do |spec_file, patterns|
        if Utils.files_grep(@changed_files, patterns).any?
          spec_files << spec_file
        end
      end

      spec_files
    end

  end
end
