require_relative 'profiler'
require_relative 'dependencies_table'

require_relative 'utils'

module DeltaTest
  class Generator

    attr_reader *%i[
      current_spec_file
      profiler
      table
    ]

    ###
    # Setup profiler and table
    #
    # @params {Boolean} _auto_teardown
    ###
    def setup!(_auto_teardown = true)
      return unless DeltaTest.active?

      return if @_setup
      @_setup = true

      DeltaTest.log('--- setup!')

      @profiler = Profiler.new
      @table    = DependenciesTable.load(DeltaTest.config.table_file_path)

      @current_spec_file = nil

      hook_on_exit { teardown! } if _auto_teardown
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

      @profiler.start
    end

    ###
    # Stop profiler and update table
    ###
    def stop!
      return unless DeltaTest.active?

      @profiler.stop

      DeltaTest.log('--- stop!')

      spec_file = @current_spec_file
      @current_spec_file = nil

      if spec_file
        @profiler.related_source_files.each do |file|
          @table.add(spec_file, file)
        end
      end
    end

    ###
    # Save table to the file
    ###
    def teardown!
      return unless @_setup
      return if @_teardown
      @_teardown = true

      DeltaTest.log('--- teardown!')

      @profiler.stop
      @table.dump(DeltaTest.config.table_file_path)
    end


  private

    ###
    # Handle exit event
    ###
    def hook_on_exit(&block)
      at_exit do
        if defined?(ParallelTests)
          break unless ParallelTests.first_process?
          ParallelTests.wait_for_other_processes_to_finish
        end

        block.call
      end
    end

  end
end
