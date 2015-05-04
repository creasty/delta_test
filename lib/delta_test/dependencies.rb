module DeltaTest
  class Dependencies < ::Set

    def union(files)
      files = files
        .map { |v| regulate_file_name(v) }
        .reject(&:nil?)

      super(files)
    end

    def add(file)
      file = regulate_file_name(file)
      super(file) if file
    end

    def regulate_file_name(file_name)
      Pathname.new(file_name).relative_path_from(DeltaTest.base_path)
    end

  end
end
