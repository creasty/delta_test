require 'set'
require 'pathname'
require 'yaml'

require_relative 'git'
require_relative 'utils'

module DeltaTest
  class Configuration

    CONFIG_FILES = [
      'delta_test.yml',
      'delta_test.yaml',
    ].freeze

    PART_FILE_EXT = '.part-%s'

    attr_accessor *%i[
      base_path
      files

      table_file
      patterns
      exclude_patterns
      custom_mappings
    ]

    # for precalculated values
    attr_reader *%i[
      filtered_files
      table_file_path
    ]

    def initialize
      update do |c|
        c.base_path        = File.expand_path('.')
        c.table_file       = 'tmp/.delta_test_dt'
        c.files            = []
        c.patterns         = []
        c.exclude_patterns = []
        c.custom_mappings  = {}
      end
    end


    #  Override setters
    #-----------------------------------------------
    ###
    # Store base_path as Pathname
    #
    # @params {String|Pathname} path
    # @return {Pathname}
    ###
    def base_path=(path)
      @base_path = Pathname.new(path)
    end

    ###
    # Store table_file as Pathname
    #
    # @params {String|Pathname} path
    # @return {Pathname}
    ###
    def table_file=(path)
      @table_file = Pathname.new(path)
    end


    #  Override getters
    #-----------------------------------------------
    ###
    # Returns file path for the table
    #
    # @params {String} part
    #
    # @return {Pathname}
    ###
    def table_file_path(part = nil)
      return unless @table_file_path

      if part
        @table_file_path.sub_ext(PART_FILE_EXT % part)
      else
        @table_file_path
      end
    end


    #  Update
    #-----------------------------------------------
    ###
    # Update, verify and precalculate
    #
    # @block
    ###
    def update
      yield self if block_given?
      validate!
      precalculate!
    end

    ###
    # Validate option values
    ###
    def validate!
      if self.base_path.relative?
        raise ValidationError.new(:base_path, 'need to be an absolute path')
      end

      unless self.files.is_a?(Array)
        raise ValidationError.new(:files, 'need to be an array')
      end

      unless self.patterns.is_a?(Array)
        raise ValidationError.new(:patterns, 'need to be an array')
      end

      unless self.exclude_patterns.is_a?(Array)
        raise ValidationError.new(:exclude_patterns, 'need to be an array')
      end

      unless self.custom_mappings.is_a?(Hash)
        raise ValidationError.new(:custom_mappings, 'need to be a hash')

        unless self.custom_mappings.values.all? { |v| v.is_a?(Array) }
          raise ValidationError.new(:custom_mappings, 'need to have an array in the contents')
        end
      end
    end

    ###
    # Precalculate some values
    ###
    def precalculate!
      filtered_files = self.files
        .map { |f| Utils.regulate_filepath(f, self.base_path) }
        .uniq

      filtered_files = Utils.files_grep(filtered_files, self.patterns, self.exclude_patterns)

      @filtered_files = Set.new(filtered_files)

      @table_file_path = Pathname.new(File.absolute_path(self.table_file, self.base_path))
    end


    #  Auto configuration
    #-----------------------------------------------
    ###
    # Use configuration file and git
    ###
    def auto_configure!
      load_from_file!
      retrive_files_from_git_index!
      update
    end

    ###
    # Load configuration file
    # And update `base_path` to the directory
    ###
    def load_from_file!
      config_file = Utils.find_file_upward(*CONFIG_FILES)

      unless config_file
        raise NoConfigurationFileFoundError
      end

      yaml = YAML.load_file(config_file)

      self.base_path = File.dirname(config_file)

      yaml.each do |k, v|
        if self.respond_to?("#{k}=")
          self.send("#{k}=", v)
        else
          raise InvalidOptionError.new(k)
        end
      end
    end

    ###
    # Retrive files from git index
    # And update `files`
    ###
    def retrive_files_from_git_index!
      unless Git.git_repo?
        raise NotInGitRepositoryError
      end

      self.files = Git.ls_files
    end

  end
end
