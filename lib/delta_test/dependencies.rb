module DeltaTest
  class Dependencies < ::Set

    def add(file)
      file = DeltaTest.regulate_filepath(file)
      super(file) if DeltaTest.config.relative_files.include?(file)
    end

    alias_method :<<, :add

  end
end
