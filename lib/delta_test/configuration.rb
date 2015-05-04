module DeltaTest
  class Configuration

    attr_accessor *%i[
      base_path
      table_file
      files
    ]

    def initialize
      self.base_path  = "/"
      self.table_file = "tmp/.delta_test_dt"
      self.files      = []

      if defined?(Rails)
        self.base_path  = Rails.root
        self.files     |= Rails.application.send(:_all_load_paths)
      end
    end

    def base_path=(path)
      @base_path = Pathname.new(path)
    end

    def table_file=(path)
      @table_file = Pathname.new(path)
    end

    def files=(_files)
      _files = Set.new(_files)
      _files.map! { |f| DeltaTest.regulate_filepath(f) }
      @files = _files
    end

  end
end
