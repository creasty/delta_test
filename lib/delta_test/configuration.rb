require 'set'
require 'pathname'
require 'yaml'

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
    ]

    # for precalculated values
    attr_reader *%i[
      relative_files
      table_file_path
    ]

    def initialize
      update do |c|
        c.base_path  = '/'
        c.table_file = 'tmp/.delta_test_dt'
        c.files      = []
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
      if @base_path.relative?
        raise '`base_path` need to be an absolute path'
      end

      unless @files && (@files.is_a?(Array) || @files.is_a?(Set))
        raise TypeError.new('`files` need to be an array or a set')
      end
    end

    def precalculate!
      @relative_files = Set.new(self.files)
      @relative_files.map! { |f| Utils.regulate_filepath(f, self.base_path) }

      @table_file_path = Pathname.new(File.absolute_path(self.table_file, self.base_path))
    end


    #  Loader
    #-----------------------------------------------
    def load_from_file!
      update do |c|
        config_file = Utils.find_file_upward(*CONFIG_FILES)

        unless config_file
          raise NoConfigurationFileFound.new('no configuration file found')
        end

        yaml = YAML.load_file(config_file)

        c.base_path = config_file

        yaml.each do |k, v|
          if c.respond_to?("#{k}=")
            c.send("#{k}=", v)
          else
            raise InvalidOption.new("invalid option: #{k}")
          end
        end
      end
    end

  end
end
