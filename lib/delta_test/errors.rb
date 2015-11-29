module DeltaTest

  class TableNotFoundError < IOError

    def initialize(table_file_path)
      @table_file_path = table_file_path
    end

    def message
      'table file not found at: `%s`' % @table_file_path
    end

  end

  class NotInGitRepositoryError < StandardError

    def message
      'the directory is not managed by git'
    end

  end

  class StatsNotFoundError < StandardError

    def message
      'no stats data found'
    end

  end

  class StatsRepositorySyncError < StandardError

    def message
      'failed to sync the stats repository'
    end

  end

  class TableFileStageError < StandardError

    def message
      'failed to stage a table file'
    end

  end

  class NoConfigurationFileFoundError < IOError

    def message
      'no configuration file found'
    end

  end

  class InvalidOptionError < StandardError

    def initialize(option)
      @option = option
    end

    def message
      'invalid option: %s' % @option
    end

  end

  class ValidationError < StandardError

    def initialize(name, message)
      @name, @_message = name, message
    end

    def message
      '`%s` %s' % [@name, @_message]
    end

  end

end
