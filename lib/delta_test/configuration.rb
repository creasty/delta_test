module DeltaTest
  class Configuration

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
      self.base_path  = "/"
      self.table_file = "tmp/.delta_test_dt"
      self.files      = []

      if defined?(Rails)
        self.base_path = Rails.root
        # FIXME
        # self.files = Rails.application.send(:_all_load_paths)
      end

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

    def base_path=(path)
      @base_path = Pathname.new(path)
    end

    def table_file=(path)
      @table_file = Pathname.new(path)
    end

  end
end
