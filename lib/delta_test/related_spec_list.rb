require 'set'

require_relative 'git'
require_relative 'dependencies_table'

module DeltaTest
  class RelatedSpecList

    attr_reader(*%i[
      git
      table
      changed_files
    ])

    def initialize
      @git = Git.new(DeltaTest.config.base_path)
    end

    ###
    # Load table from the file
    ###
    def load_table!(table_file_path)
      unless File.exist?(table_file_path)
        raise TableNotFoundError.new(table_file_path)
      end

      @table = DependenciesTable.load(table_file_path)
    end

    ###
    # Retrive changed files in git diff
    #
    # @params {String} base
    # @params {String} head
    ###
    def retrive_changed_files!(commit)
      unless @git.git_repo?
        raise NotInGitRepositoryError
      end

      @changed_files = @git.changed_files(commit)
    end

    ###
    # Return if full tests are related
    #
    # @return {Boolean}
    ###
    def full_tests?
      return false unless @changed_files

      @full_tests ||= if DeltaTest.config.full_test_patterns.empty?
          false
        else
          Utils.files_grep(
            @changed_files,
            DeltaTest.config.full_test_patterns
          ).any?
        end
    end

    ###
    # Dependent spec files
    #
    # @return {Set|Nil}
    ###
    def dependents
      return nil unless @changed_files && @table

      return @dependents if @dependents
      @dependents = Set.new

      @table.each do |spec_file, dependencies|
        dependent = @changed_files.include?(spec_file) \
          || (dependencies.map(&:to_s) & @changed_files).any?

        @dependents << spec_file if dependent
      end

      @dependents
    end

    ###
    # Custom spec files
    #
    # @return {Set|Nil}
    ###
    def customs
      return nil unless @changed_files

      return @customs if @customs
      @customs = Set.new

      DeltaTest.config.custom_mappings.each do |spec_file, patterns|
        if Utils.files_grep(@changed_files, patterns).any?
          @customs << spec_file
        end
      end

      @customs
    end

    ###
    # Full spec files
    #
    # @return {Set|Nil}
    ###
    def full
      return nil unless @table

      @full ||= Set.new(@table.keys)
    end

    ###
    # Calculate related spec files
    #
    # @return {Set<String>}
    ###
    def related_spec_files
      if full_tests?
        full
      else
        dependents | customs
      end
    end

  end
end
