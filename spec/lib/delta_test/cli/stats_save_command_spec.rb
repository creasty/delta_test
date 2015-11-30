require 'delta_test/cli/stats_save_command'
require 'delta_test/stats'

describe DeltaTest::CLI::StatsSaveCommand do

  let(:command) { DeltaTest::CLI::StatsSaveCommand.new([]) }

  let(:head_commit) { '1111111111111111111111111111111111111111' }

  let(:tmp_dir) { DeltaTest.config.tmp_table_file.parent }

  let(:tmp_table_1_path) { tmp_dir.join('table_1.marshal') }
  let(:tmp_table_1) do
    DeltaTest::DependenciesTable.new.tap do |table|
      table['spec/foo_spec.rb'] << 'lib/foo.rb'
      table['spec/bar_spec.rb'] << 'lib/bar.rb'
      table['spec/mixed_spec.rb'] << 'lib/foo.rb'

      FakeFS::FileSystem.add(tmp_table_1_path, FakeFS::FakeFile.new)
      table.dump(tmp_table_1_path)
    end
  end

  let(:tmp_table_2_path) { tmp_dir.join('table_2.marshal') }
  let(:tmp_table_2) do
    DeltaTest::DependenciesTable.new.tap do |table|
      table['spec/baz_spec.rb'] << 'lib/baz.rb'
      table['spec/mixed_spec.rb'] << 'lib/bar.rb'

      FakeFS::FileSystem.add(tmp_table_2_path, FakeFS::FakeFile.new)
      table.dump(tmp_table_2_path)
    end
  end

  let(:whole_table_path) { command.stats.table_file_path }
  let(:whole_table) do
    DeltaTest::DependenciesTable.new.tap do |table|
      table['spec/foo_spec.rb'] << 'lib/foo.rb'
      table['spec/bar_spec.rb'] << 'lib/bar.rb'
      table['spec/baz_spec.rb'] << 'lib/baz.rb'
      table['spec/mixed_spec.rb'] << 'lib/foo.rb'
      table['spec/mixed_spec.rb'] << 'lib/bar.rb'
    end
  end

  before do
    allow_any_instance_of(DeltaTest::Git).to receive(:rev_parse).with('HEAD').and_return(head_commit)
  end

  describe '#invoke!' do

    before do
      allow(command.table).to receive(:any?).and_return(true)
    end

    it 'should execute procedures' do
      expect(command).to receive(:load_tmp_table_files).and_return(nil).once.ordered
      expect(command).to receive(:cleanup_tmp_table_files).and_return(nil).once.ordered
      expect(command).to receive(:save_table_file).and_return(nil).once.ordered
      expect(command).to receive(:stage_table_file).and_return(nil).once.ordered
      expect(command).to receive(:sync_table_file).and_return(nil).once.ordered
      command.invoke!
    end

    context 'with --no-sync' do

      let(:command) { DeltaTest::CLI::StatsSaveCommand.new(['--no-sync']) }

      it 'should not sync the repository' do
        expect(command).to receive(:load_tmp_table_files).and_return(nil).once.ordered
        expect(command).to receive(:cleanup_tmp_table_files).and_return(nil).once.ordered
        expect(command).to receive(:save_table_file).and_return(nil).once.ordered
        expect(command).to receive(:stage_table_file).and_return(nil).once.ordered
        expect(command).not_to receive(:sync_table_file)
        command.invoke!
      end

    end

    context 'no table data' do

      it 'should not create an empty table file' do
        allow(command.table).to receive(:any?).and_return(false)
        expect(command).to receive(:load_tmp_table_files).and_return(nil).once.ordered
        expect(command).to receive(:cleanup_tmp_table_files).and_return(nil).once.ordered
        expect(command).not_to receive(:save_table_file)
        expect(command).not_to receive(:stage_table_file)
        expect(command).not_to receive(:sync_table_file)
        command.invoke!
      end

    end

  end

  describe '#tmp_table_files' do

    before do
      tmp_table_1
      tmp_table_2
    end

    it 'should return all table files in the temporary directory' do
      expect(command.tmp_table_files).to eq([tmp_table_1_path.to_s, tmp_table_2_path.to_s])
    end

  end

  describe '#stats' do

    it 'should initialize Stats with head: true' do
      expect(DeltaTest::Stats).to receive(:new).with(head: true).and_return(nil).once
      command.stats
    end

  end

  describe '#load_tmp_table_files' do

    before do
      tmp_table_1
      tmp_table_2
    end

    it 'should load all temporary tables and merge them into one' do
      expect(command.table).to be_empty
      expect {
        command.load_tmp_table_files
      }.not_to raise_error
      expect(command.table).to eq(whole_table)
    end

  end

  describe '#cleanup_tmp_table_files' do

    before do
      tmp_table_1
      tmp_table_2
    end

    it 'should load all temporary tables and merge them into one' do
      expect(File.directory?(tmp_dir)).to be(true)
      expect {
        command.cleanup_tmp_table_files
      }.not_to raise_error
      expect(File.directory?(tmp_dir)).to be(false)
    end

  end

  describe '#save_table_file' do

    before do
      tmp_table_1
      tmp_table_2
    end

    it 'should save the table file' do
      expect(File.exist?(whole_table_path)).to be(false)
      expect {
        command.save_table_file
      }.not_to raise_error
      expect(File.exist?(whole_table_path)).to be(true)
    end

  end

  describe '#stage_table_file' do

    before do
      FakeFS::FileSystem.add(whole_table_path, FakeFS::FakeFile.new)
      whole_table.dump(whole_table_path)
    end

    it 'should add and commit the table file' do
      expect(command.stats.stats_git).to receive(:add).with(whole_table_path).and_return(true)
      expect(command.stats.stats_git).to receive(:commit).with(head_commit).and_return(true)
      expect {
        command.stage_table_file
      }.not_to raise_error
    end

    it 'should raise an error if failed to stage the table file' do
      expect(command.stats.stats_git).to receive(:add).with(whole_table_path).and_return(true)
      expect(command.stats.stats_git).to receive(:commit).with(head_commit).and_return(false)
      expect {
        command.stage_table_file
      }.to raise_error(DeltaTest::TableFileStageError)
    end

  end

  describe '#sync_table_file' do

    it 'should do nothing if no remote is configured' do
      allow(command.stats.stats_git).to receive(:has_remote?).and_return(false)
      expect(command.stats.stats_git).not_to receive(:pull)
      expect(command.stats.stats_git).not_to receive(:push)
      expect {
        command.sync_table_file
      }.not_to raise_error
    end

    it 'should pull and push' do
      allow(command.stats.stats_git).to receive(:has_remote?).and_return(true)
      expect(command.stats.stats_git).to receive(:pull).and_return(true)
      expect(command.stats.stats_git).to receive(:push).and_return(true)
      expect {
        command.sync_table_file
      }.not_to raise_error
    end

    it 'should raise an error if failed to sync the repository' do
      allow(command.stats.stats_git).to receive(:has_remote?).and_return(true)
      expect(command.stats.stats_git).to receive(:pull).and_return(true)
      expect(command.stats.stats_git).to receive(:push).and_return(false)
      expect {
        command.sync_table_file
      }.to raise_error(DeltaTest::StatsRepositorySyncError)
    end

  end

end
