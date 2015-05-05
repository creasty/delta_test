module DeltaTest
  class Configuration

    attr_accessor *%i[
      base_path
      table_file
      files
    ]

    attr_reader :relative_files

    def initialize
      self.base_path  = "/"
      self.table_file = "tmp/.delta_test_dt"
      self.files      = []

      if defined?(Rails)
        self.base_path = Rails.root
        # FIXME
        # self.files = Rails.application.send(:_all_load_paths)
      end

      precalculate!
    end

    def precalculate!
      @relative_files = Set.new(self.files)
      @relative_files.map! { |f| DeltaTest.regulate_filepath(f) }
    end

    def base_path=(path)
      @base_path = Pathname.new(path)
    end

    def table_file=(path)
      @table_file = Pathname.new(path)
    end

  end
end
