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
    ].map(&:freeze).freeze

    attr_accessor(*%i[
      base_path
      stats_path
      stats_life

      files

      full_test_patterns
      full_test_branches

      patterns
      exclude_patterns
      custom_mappings
    ])

    # for precalculated values
    attr_reader(*%i[
      filtered_files
    ])

    validate :base_path, 'need to be an absolute path' do
      self.base_path.absolute? rescue false
    end

    validate :base_path, 'need to be managed by git' do
      Git.new(self.base_path).git_repo?
    end

    validate :stats_path, 'need to be an absolute path' do
      self.stats_path.absolute? rescue false
    end

    validate :stats_path, 'need to be managed by git' do
      Git.new(self.stats_path).git_repo?
    end

    validate :stats_life, 'need to be a real number' do
      self.stats_life.is_a?(Integer) && self.stats_life > 0
    end

    validate :files, 'need to be an array' do
      self.files.is_a?(Array)
    end

    validate :full_test_patterns, 'need to be an array' do
      self.full_test_patterns.is_a?(Array)
    end

    validate :full_test_branches, 'need to be an array' do
      self.full_test_branches.is_a?(Array)
    end

    validate :patterns, 'need to be an array' do
      self.patterns.is_a?(Array)
    end

    validate :exclude_patterns, 'need to be an array' do
      self.exclude_patterns.is_a?(Array)
    end

    validate :custom_mappings, 'need to be a hash' do
      self.custom_mappings.is_a?(Hash)
    end

    validate :custom_mappings, 'need to have an array in the contents' do
      self.custom_mappings.values.all? { |v| v.is_a?(Array) }
    end

    def initialize
      update(validate: false) do |c|
        c.base_path  = File.expand_path('.')
        c.stats_path = File.expand_path('tmp/delta_test_stats')
        c.stats_life = 1000  # commits

        c.files     = []

        c.full_test_patterns = []
        c.full_test_branches = []

        c.patterns           = []
        c.exclude_patterns   = []
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
    def update(validate: true)
      yield self if block_given?
      validate! if validate
      precalculate!
    end

    ###
    # Precalculate some values
    ###
    def precalculate!
      filtered_files = self.files
        .map { |f| Utils.regulate_filepath(f, self.base_path) }
        .uniq
      @filtered_files = Utils.files_grep(filtered_files, self.patterns, self.exclude_patterns).to_set

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
      yaml_dir = File.dirname(config_file)

      _base_path = yaml.delete('base_path')
      self.base_path = _base_path ? File.absolute_path(_base_path, yaml_dir) : yaml_dir

      _stats_path = yaml.delete('stats_path')
      self.stats_path = File.absolute_path(_stats_path, yaml_dir) if _stats_path

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
      self.files = Git.new(self.base_path).ls_files
    end


    #  Getters
    #-----------------------------------------------
    ###
    # Temporary table file path
    #
    # @return {Pathname}
    ###
    def tmp_table_file
      self.stats_path.join('tmp', DeltaTest.tester_id)
    end

  end
end
