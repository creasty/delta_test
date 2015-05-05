module DeltaTest
  class Generator

    attr_reader *%i[
      current_spec_file
      table
    ]

    def setup!(_auto_teardown = true)
      return unless DeltaTest.active?

      return if @_setup
      @_setup = true

      puts "--- setup!"

      @analyzer        = Analyzer.new
      @table_file_path = DeltaTest.base_path.join(DeltaTest.table_file)
      @table           = DependenciesTable.load(@table_file_path, Dependencies)

      @current_spec_file = nil

      at_exit { teardown! } if _auto_teardown
    end

    def start!(spec_file)
      return unless DeltaTest.active?

      puts "--- start!(%s)" % spec_file

      @current_spec_file = spec_file
      @analyzer.start
    end

    def stop!
      return unless DeltaTest.active?

      puts "--- stop!"

      spec_file = @current_spec_file
      @current_spec_file = nil

      @analyzer.stop

      if spec_file
        @analyzer.related_source_files.each do |file|
          @table[spec_file] << file
        end
      end
    end

    def teardown!
      return unless @_setup
      return if @_teardown
      @_teardown = true

      puts "--- teardown!"

      @analyzer.stop
      @table.dump(@table_file_path)
    end

  end
end