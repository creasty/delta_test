require_relative 'utils'

module DeltaTest
  class Dependencies < ::Set

    def add(file)
      file = Utils.regulate_filepath(file, DeltaTest.config.base_path)
      super(file) if DeltaTest.config.filtered_files.include?(file)
    end

    alias_method :<<, :add

  end
end
