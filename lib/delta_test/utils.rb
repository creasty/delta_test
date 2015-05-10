module DeltaTest
  module Utils
    class << self

      ###
      # Convert to relative and clean path
      #
      # @params {String|Pathname} file
      # @params {Pathname} base_path
      #
      # @return {Pathname}
      ###
      def regulate_filepath(file, base_path)
        file = Pathname.new(file)
        file = file.relative_path_from(base_path) rescue file
        file.cleanpath
      end

      ###
      # Find file upward from pwd
      #
      # @params {String} file_names
      #
      # @return {String}
      ###
      def find_file_upward(*file_names)
        pwd  = Dir.pwd
        base = Hash.new { |h, k| h[k] = pwd }
        file = {}

        while base.values.all? { |b| '.' != b && '/' != b }
          file_names.each do |name|
            file[name] = File.join(base[name], name)
            base[name] = File.dirname(base[name])

            return file[name] if File.exists?(file[name])
          end
        end

        nil
      end

      ###
      # Wildcard pattern matching against a file list
      #
      # @params {Array<T as String|Pathname>} files
      # @params {Array<String>} patterns
      # @params {Array<String>} exclude_patterns
      #
      # @return {Array<T>}
      ###
      def files_grep(files, patterns = [], exclude_patterns = [])
        patterns = patterns
          .map { |p| grep_pattern_to_regexp(p) }
        exclude_patterns = exclude_patterns
          .map { |p| grep_pattern_to_regexp(p) }

        any_patterns         = patterns.any?
        any_exclude_patterns = exclude_patterns.any?

        files.select do |file|
          matcher = ->(p) { p === file.to_s }

          (
            !any_patterns || patterns.any?(&matcher)
          ) && (
            !any_exclude_patterns || !exclude_patterns.any?(&matcher)
          )
        end
      end


    private

      ###
      # Convert file wildcard pattern to a regular expression
      #
      # @params {String} pattern
      #
      # @return {String}
      ###
      def grep_pattern_to_regexp(pattern)
        pattern = Regexp.escape(pattern)
          .gsub('\*\*/', '.*/?')
          .gsub('\*\*', '.*')
          .gsub('\*', '[^/]*')

        Regexp.new('^%s$' % pattern)
      end

    end
  end
end
