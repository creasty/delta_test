module DeltaTest
  class Dependencies < ::Set

    def union(files)
      files = files
        .map { |v| DeltaTest.regulate_filepath(v) }
        .reject(&:nil?)

      super(files)
    end

    def add(file)
      file = DeltaTest.regulate_filepath(file)
      super(file) if file
    end

  end
end
