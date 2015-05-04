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

    def files=(files)
      files = Set.new(files)
      files.map! { |f| Pathname.new(f) }
      @files = files
    end

    def relative_files
      self.files
        .dup
        .map! { |f| f.relative_path_from(self.base_path) }
    end

  end
end
