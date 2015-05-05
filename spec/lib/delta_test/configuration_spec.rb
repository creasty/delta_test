describe DeltaTest::Configuration do

  let(:configuration) { DeltaTest::Configuration.new }

  describe "::new" do

    let(:options) do
      %i[
        base_path
        table_file
        files
      ]
    end

    it "should set default values" do
      options.each do |option|
        expect(configuration.respond_to?(option)).to be(true)
        expect(configuration.send(option)).not_to be_nil
      end
    end

  end

  describe "#base_path, #base_path=" do

    it "should return an instance of Pathname" do
      expect(configuration.base_path).to be_a(Pathname)
    end

    it "should store an instance of Pathname from a string in the setter" do
      path = 'foo/bar'

      expect {
        configuration.base_path = path
      }.not_to raise_error

      expect(configuration.base_path).to be_a(Pathname)
      expect(configuration.base_path.to_s).to eq(path)
    end

  end

  describe "#table_file, #table_file=" do

    it "should return an instance of Pathname" do
      expect(configuration.table_file).to be_a(Pathname)
    end

    it "should store an instance of Pathname from a string in the setter" do
      path = 'foo/bar'

      expect {
        configuration.table_file = path
      }.not_to raise_error

      expect(configuration.table_file).to be_a(Pathname)
      expect(configuration.table_file.to_s).to eq(path)
    end

  end

  describe "#validate!" do

    describe "#base_path" do

      it "should raise an error if `base_path` is a relative path" do
        configuration.base_path = "relative/path"

        expect {
          configuration.validate!
        }.to raise_error(/base_path/)
      end

      it "should not raise if `base_path` is a absolute path" do
        configuration.base_path = "/absolute/path"

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

    describe "#files" do

      it "should raise an error if `files` is not set" do
        configuration.files = nil

        expect {
          configuration.validate!
        }.to raise_error(/files/)
      end

      it "should raise an error if `files` is neither an array or a set" do
        configuration.files = {}

        expect {
          configuration.validate!
        }.to raise_error(/files/)
      end

      it "should not raise if `files` is an array" do
        configuration.files = []

        expect {
          configuration.validate!
        }.not_to raise_error
      end

      it "should not raise if `files` is a set" do
        configuration.files = Set.new

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

  end

  describe "#precalculate!" do

    describe "#relative_files" do

      it "should return an instance of Set" do
        configuration.precalculate!
        expect(configuration.relative_files).to be_a(Set)
      end

      it "should return a set of relative file paths" do
        base_path = '/base_path'
        files_array = [
          '/base_path/foo/bar',
          '/base_path/foo/bar',
          '/base_path/foo/bar/baz',
        ]
        relative_set = Set[
          Pathname.new('foo/bar'),
          Pathname.new('foo/bar/baz'),
        ]

        configuration.base_path = base_path
        configuration.files     = files_array

        configuration.precalculate!
        expect(configuration.relative_files).to eq(relative_set)
      end

    end

    describe "#table_file_path" do

      it "should return an absolute path to the table file if `table_file` is a relative" do
        configuration.base_path  = "/base_path"
        configuration.table_file = "somewhere/table_file"

        configuration.precalculate!
        expect(configuration.table_file_path).to eq(Pathname.new("/base_path/somewhere/table_file"))
      end

      it "should return the same value to the table file if `table_file` is a absolute" do
        configuration.base_path  = "/base_path"
        configuration.table_file = "/somewhere/table_file"

        configuration.precalculate!
        expect(configuration.table_file_path).to eq(Pathname.new("/somewhere/table_file"))
      end

    end

  end

end
