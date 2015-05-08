require "set"
require "pathname"
require "yaml"

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
        c.base_path  = "/"
        c.table_file = "tmp/.delta_test_dt"
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
        raise "`base_path` need to be an absolute path"
      end

      unless @files && (@files.is_a?(Array) || @files.is_a?(Set))
        raise TypeError.new("`files` need to be an array or a set")
      end
    end

    def precalculate!
      @relative_files = Set.new(self.files)
      @relative_files.map! { |f| DeltaTest.regulate_filepath(f) }

      @table_file_path = Pathname.new(File.absolute_path(self.table_file, self.base_path))
    end

  end
end
