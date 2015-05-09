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

    attr_accessor *%i[
      base_path
      table_file
      files
      patterns
      exclude_patterns
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
      end
    end


    #  Override setters
    #-----------------------------------------------
    def base_path=(path)
      @base_path = Pathname.new(path)
    end

    def table_file=(path)
      @table_file = Pathname.new(path)
    end


    #  Update
    #-----------------------------------------------
    def update
      yield self if block_given?
      validate!
      precalculate!
    end

    def validate!
      if self.base_path.relative?
        raise '`base_path` need to be an absolute path'
      end

      unless self.files.is_a?(Array)
        raise TypeError.new('`files` need to be an array')
      end

      unless self.patterns.is_a?(Array)
        raise TypeError.new('`patterns` need to be an array')
      end

      unless self.exclude_patterns.is_a?(Array)
        raise TypeError.new('`exclude_patterns` need to be an array')
      end
    end

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
    def auto_configure!
      load_from_file!
      retrive_files_from_git_index!
      update
    end

    def load_from_file!
      config_file = Utils.find_file_upward(*CONFIG_FILES)

      unless config_file
        raise NoConfigurationFileFound.new('no configuration file found')
      end

      yaml = YAML.load_file(config_file)

      self.base_path = config_file

      yaml.each do |k, v|
        if self.respond_to?("#{k}=")
          self.send("#{k}=", v)
        else
          raise InvalidOption.new("invalid option: #{k}")
        end
      end
    end

    def retrive_files_from_git_index!
      unless Git.git_repo?
        raise NotInGitRepository.new('the directory is not managed by git')
      end

      self.files = Git.ls_files
    end

  end
end
