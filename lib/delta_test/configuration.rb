require 'set'
require 'pathname'
require 'yaml'

require_relative 'git'
require_relative 'utils'

module DeltaTest
  class Configuration

    module Validator

      def self.included(base)
        base.include(InstanceMethods)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def _validators
          @_validators ||= []
        end

        def validate(attr, message, &block)
          _validators << [attr, message, block]
        end

      end

      module InstanceMethods

        def validate!
          self.class._validators.each do |attr, message, block|
            raise ValidationError.new(attr, message) unless self.instance_eval(&block)
          end
        end

      end

    end

    include Validator

    CONFIG_FILES = [
      'delta_test.yml',
      'delta_test.yaml',
    ].freeze

    PART_FILE_EXT = '.part-%s'

    attr_accessor(*%i[
      base_path
      files

      stats_repository
      stats_path

      patterns
      exclude_patterns
      full_test_patterns
      custom_mappings
    ])

    # for precalculated values
    attr_reader(*%i[
      filtered_files
    ])

    validate :base_path, 'need to be an absolute path' do
      self.base_path.absolute? rescue false
    end

    validate :files, 'need to be an array' do
      self.files.is_a?(Array)
    end

    validate :patterns, 'need to be an array' do
      self.patterns.is_a?(Array)
    end

    validate :stats_path, 'need to be an absolute path' do
      self.stats_path.absolute? rescue false
    end

    validate :exclude_patterns, 'need to be an array' do
      self.exclude_patterns.is_a?(Array)
    end

    validate :full_test_patterns, 'need to be an array' do
      self.full_test_patterns.is_a?(Array)
    end

    validate :custom_mappings, 'need to be a hash' do
      self.custom_mappings.is_a?(Hash)
    end

    validate :custom_mappings, 'need to have an array in the contents' do
      self.custom_mappings.values.all? { |v| v.is_a?(Array) }
    end

    def initialize
      update do |c|
        c.base_path = File.expand_path('.')
        c.files     = []

        c.stats_repository = nil
        c.stats_path       = File.expand_path('tmp/delta_test_stats')

        c.patterns           = []
        c.exclude_patterns   = []
        c.full_test_patterns = []
        c.custom_mappings    = {}
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
      return unless path
      @base_path = Pathname.new(path)
    end

    ###
    # Store stats_path as Pathname
    #
    # @params {String|Pathname} path
    # @return {Pathname}
    ###
    def stats_path=(path)
      return unless path
      @stats_path = Pathname.new(path)
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
    # Precalculate some values
    ###
    def precalculate!
      filtered_files = self.files
        .map { |f| Utils.regulate_filepath(f, self.base_path) }
        .uniq

      filtered_files = Utils.files_grep(filtered_files, self.patterns, self.exclude_patterns)

      @filtered_files = Set.new(filtered_files)

      @stats_path = Pathname.new(File.absolute_path(self.stats_path, self.base_path))
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
      git = Git.new

      unless git.git_repo?
        raise NotInGitRepositoryError
      end

      self.files = git.ls_files
    end


    #  Getters
    #-----------------------------------------------
    ###
    # Temporary stats file path
    #
    # @return {Pathname}
    ###
    def tmp_stats_file_path
      self.stats_path.join('tmp', DeltaTest.tester_id)
    end

  end
end
