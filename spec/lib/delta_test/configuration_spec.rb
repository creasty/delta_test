describe DeltaTest::Configuration do

  let(:configuration) do
    DeltaTest::Configuration.new.tap do |c|
      c.stats_repository = 'git:///test/test.git'
    end
  end

  describe '::new' do

    let(:options) do
      %i[
        base_path
        files
      ]
    end

    it 'should set default values' do
      options.each do |option|
        expect(configuration.respond_to?(option)).to be(true)
        expect(configuration.send(option)).not_to be_nil
      end
    end

  end

  describe '#base_path, #base_path=' do

    it 'should return an instance of Pathname' do
      expect(configuration.base_path).to be_a(Pathname)
    end

    it 'should store an instance of Pathname from a string in the setter' do
      path = 'foo/bar'

      expect {
        configuration.base_path = path
      }.not_to raise_error

      expect(configuration.base_path).to be_a(Pathname)
      expect(configuration.base_path.to_s).to eq(path)
    end

  end

  describe '#stats_path, #stats_path=' do

    it 'should return an instance of Pathname' do
      expect(configuration.stats_path).to be_a(Pathname)
    end

    it 'should store an instance of Pathname from a string in the setter' do
      path = 'foo/bar'

      expect {
        configuration.stats_path = path
      }.not_to raise_error

      expect(configuration.stats_path).to be_a(Pathname)
      expect(configuration.stats_path.to_s).to eq(path)
    end

  end

  describe '#validate!' do

    describe '#base_path' do

      it 'should raise an error if `base_path` is a relative path' do
        configuration.base_path = "relative/path"

        expect {
          configuration.validate!
        }.to raise_error(/base_path/)
      end

      it 'should not raise if `base_path` is a absolute path' do
        configuration.base_path = "/absolute/path"

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

    describe '#files' do

      it 'should raise an error if `files` is not set' do
        configuration.files = nil

        expect {
          configuration.validate!
        }.to raise_error(/files/)
      end

      it 'should raise an error if `files` is neither an array' do
        configuration.files = {}

        expect {
          configuration.validate!
        }.to raise_error(/files/)
      end

      it 'should not raise if `files` is an array' do
        configuration.files = []

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

    describe '#patterns' do

      it 'should raise an error if `patterns` is not set' do
        configuration.patterns = nil

        expect {
          configuration.validate!
        }.to raise_error(/patterns/)
      end

      it 'should raise an error if `patterns` is neither an array' do
        configuration.patterns = {}

        expect {
          configuration.validate!
        }.to raise_error(/patterns/)
      end

      it 'should not raise if `patterns` is an array' do
        configuration.patterns = []

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

    describe '#exclude_patterns' do

      it 'should raise an error if `exclude_patterns` is not set' do
        configuration.exclude_patterns = nil

        expect {
          configuration.validate!
        }.to raise_error(/patterns/)
      end

      it 'should raise an error if `exclude_patterns` is neither an array' do
        configuration.exclude_patterns = {}

        expect {
          configuration.validate!
        }.to raise_error(/exclude_patterns/)
      end

      it 'should not raise if `exclude_patterns` is an array' do
        configuration.exclude_patterns = []

        expect {
          configuration.validate!
        }.not_to raise_error
      end

    end

  end

  describe '#precalculate!' do

    describe '#filtered_files' do

      it 'should return an instance of Set' do
        configuration.precalculate!
        expect(configuration.filtered_files).to be_a(Set)
      end

      it 'should return a set of filtered file paths' do
        base_path = '/base_path'
        patterns = [
          '**/*r'
        ]
        files = [
          '/base_path/foo/bar',
          '/base_path/foo/bar',
          '/base_path/foo/bar/baz',
        ]
        filtered_files = Set[
          Pathname.new('foo/bar'),
        ]

        configuration.base_path = base_path
        configuration.files     = files
        configuration.patterns  = patterns

        configuration.precalculate!
        expect(configuration.filtered_files).to eq(filtered_files)
      end

    end

    describe '#stats_path' do

      it 'should return an absolute path to the table file if `stats_path` is a relative' do
        configuration.base_path  = '/base_path'
        configuration.stats_path = 'somewhere/stats_path'

        configuration.precalculate!
        expect(configuration.stats_path).to eq(Pathname.new('/base_path/somewhere/stats_path'))
      end

      it 'should return the same value to the table file if `stats_path` is a absolute' do
        configuration.base_path  = '/base_path'
        configuration.stats_path = '/somewhere/stats_path'

        configuration.precalculate!
        expect(configuration.stats_path).to eq(Pathname.new('/somewhere/stats_path'))
      end

    end

  end

  describe '#tmp_stats_file_path' do

      it 'should return a path with a part extension' do
        configuration.base_path  = '/base_path'
        configuration.stats_path = 'somewhere/stats_path'
        tmp_stats_file_path = Pathname.new('%s/%s/tmp/%s' % [configuration.base_path, configuration.stats_path, DeltaTest.tester_id])

        configuration.precalculate!
        expect(configuration.tmp_stats_file_path).to eq(tmp_stats_file_path)
      end

    end

  describe '#update' do

    it 'should call `validate!` and `precalculate!` after the block' do
      dummy = double
      allow(dummy).to receive(:not_yet_called)
      allow(dummy).to receive(:already_called)

      expect(dummy).to receive(:not_yet_called).with(no_args).once.ordered
      expect(configuration).to receive(:validate!).with(no_args).once.ordered
      expect(configuration).to receive(:precalculate!).with(no_args).once.ordered
      expect(dummy).to receive(:already_called).with(no_args).once.ordered

      configuration.update do |config|
        dummy.not_yet_called
      end

      dummy.already_called
    end

  end

  describe 'Auto configuration' do

    describe '#auto_configure!' do

      it 'should call `load_from_file!`, `retrive_files_from_git_index!` and `update`' do
        allow(configuration).to receive(:load_from_file!).and_return(true)
        allow(configuration).to receive(:retrive_files_from_git_index!).and_return(true)

        expect(configuration).to receive(:load_from_file!).with(no_args).once.ordered
        expect(configuration).to receive(:retrive_files_from_git_index!).with(no_args).once.ordered
        expect(configuration).to receive(:update).with(no_args).once.ordered

        configuration.auto_configure!
      end

    end

    describe '#load_from_file!' do

      let(:pwd)            { '/path/to/pwd' }
      let(:yaml_file_path) { '/path/to/delta_test.yml' }
      let(:stats_path)     { '/path/to/stats_path' }

      let(:yaml_file) do
        file = FakeFS::FakeFile.new

        file.content = <<-YAML
stats_path: #{stats_path}
        YAML

        file
      end

      before do
        FakeFS::FileSystem.add(pwd)
        Dir.chdir(pwd)
      end

      it 'should raise an error if no file is found' do
        expect {
          configuration.load_from_file!
        }.to raise_error(DeltaTest::NoConfigurationFileFoundError)
      end

      it 'should set `base_path` to the directory of yaml file' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)

        expect {
          configuration.load_from_file!
        }.not_to raise_error

        expect(configuration.base_path).to eq(Pathname.new(File.dirname(yaml_file_path)))
      end

      it 'should set other option values from yaml' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)

        expect {
          configuration.load_from_file!
        }.not_to raise_error

        expect(configuration.stats_path).to eq(Pathname.new(stats_path))
      end

      it 'should raise an error if there is invalid option in yaml' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)
        yaml_file.content = <<-YAML
  foo: true
        YAML

        expect {
          configuration.load_from_file!
        }.to raise_error(DeltaTest::InvalidOptionError, /foo/)
      end

    end

    describe 'retrive_files_from_git_index!' do

      it 'should raise an error if not in git repo' do
        allow(DeltaTest::Git).to receive(:git_repo?).with(no_args).and_return(false)

        expect {
          configuration.retrive_files_from_git_index!
        }.to raise_error(DeltaTest::NotInGitRepositoryError)
      end

      it 'should set `files` from the file indices of git' do
        files = [
          'a/file_1',
          'a/file_2',
        ]

        allow(DeltaTest::Git).to receive(:git_repo?).with(no_args).and_return(true)
        allow(DeltaTest::Git).to receive(:ls_files).with(no_args).and_return(files)

        expect {
          configuration.retrive_files_from_git_index!
        }.not_to raise_error

        expect(configuration.files).to eq(files)
      end

    end

  end

end
