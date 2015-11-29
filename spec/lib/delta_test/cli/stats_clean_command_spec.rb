require 'delta_test/cli/stats_clean_command'

describe DeltaTest::CLI::StatsCleanCommand do

  let(:tmp_dir) { DeltaTest.config.tmp_table_file.parent }
  let(:command) { DeltaTest::CLI::StatsCleanCommand.new([]) }

  describe '#invoke!' do

    it 'should call cleanup_tmp_table_files' do
      expect(command).to receive(:cleanup_tmp_table_files).and_return(nil)
      command.invoke!
    end

  end

  describe '#cleanup_tmp_table_files' do

    it 'should not raise any error if a tmporary directory does not exist' do
      expect(File.directory?(tmp_dir)).to be(false)
      expect {
        command.invoke!
      }.not_to raise_error
    end

    it 'should delete all files in the temporary directory' do
      FakeFS::FileSystem.add(tmp_dir.join('foo'), FakeFS::FakeFile.new)
      FakeFS::FileSystem.add(tmp_dir.join('bar'), FakeFS::FakeFile.new)

      expect(File.directory?(tmp_dir)).to be(true)
      expect {
        command.invoke!
      }.not_to raise_error
      expect(File.directory?(tmp_dir)).to be(false)
    end

  end

end
