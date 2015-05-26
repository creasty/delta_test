require 'singleton'

require_relative 'profiler'
require_relative 'dependencies_table'

require_relative 'utils'

module DeltaTest
  class Generator

    attr_reader *%i[
      current_spec_file
      table
    ]

    ###
    # Setup table
    ###
    def setup!
      return unless DeltaTest.active?

      return if @_setup
      @_setup = true

      DeltaTest.log('--- setup!')

      @table = DependenciesTable.load(DeltaTest.config.table_file_path)

      @current_spec_file = nil
    end

    ###
    # Start profiler for the spec file
    #
    # @params {String} spec_file
    ###
    def start!(spec_file)
      return unless DeltaTest.active?

      DeltaTest.log('--- start!(%s)' % spec_file)

      @current_spec_file = Utils.regulate_filepath(spec_file, DeltaTest.config.base_path).to_s

      Profiler.start!
    end

    ###
    # Stop profiler and update table
    ###
    def stop!
      return unless DeltaTest.active?

      Profiler.stop!

      DeltaTest.log('--- stop!')

      spec_file = @current_spec_file
      @current_spec_file = nil

      if spec_file
        Profiler.last_result.each do |file|
          @table.add(spec_file, file)
        end
      end

      DeltaTest::Profiler.clean!
    end

    ###
    # Save table to the file
    ###
    def teardown!
      return unless @_setup
      return if @_teardown
      @_teardown = true

      DeltaTest.log('--- teardown!')

      Profiler.clean!

      if defined?(ParallelTests)
        if ParallelTests.first_process?
          ParallelTests.wait_for_other_processes_to_finish

          table_file_path = DeltaTest.config.table_file_path('*')

          Dir.glob(table_file_path).each do |part_file|
            part_table = DependenciesTable.load(part_file)
            @table.reverse_merge!(part_table)
          end
        else
          table_file_path = DeltaTest.config.table_file_path(ENV['TEST_ENV_NUMBER'])

          @table.dump(table_file_path)
          return
        end
      end

      @table.dump(DeltaTest.config.table_file_path)
    end

    ###
    # Hook teardown! on exit
    ###
    def hook_on_exit
      at_exit { teardown! }
    end

  end

  class GeneratorSingleton < Generator
    include Singleton
  end
end
