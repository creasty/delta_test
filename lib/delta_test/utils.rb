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

    end
  end
end
