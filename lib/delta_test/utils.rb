module DeltaTest
  module Utils
    class << self

      def regulate_filepath(file, base_path)
        file = Pathname.new(file)
        file = file.relative_path_from(base_path) rescue file
        file.cleanpath
      end

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

      def files_grep(files, patterns = [], exclude_patterns = [])
        patterns = patterns
          .map { |p| grep_pattern_to_regexp(p) }
        exclude_patterns = exclude_patterns
          .map { |p| grep_pattern_to_regexp(p) }

        any_patterns         = patterns.any?
        any_exclude_patterns = exclude_patterns.any?

        files.select do |file|
          matcher = ->(p) { p === file }

          (
            !any_patterns || patterns.any?(&matcher)
          ) && (
            !any_exclude_patterns || !exclude_patterns.any?(&matcher)
          )
        end
      end


    private

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
