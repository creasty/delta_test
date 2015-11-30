require 'delta_test/stats'
require 'delta_test/git'

describe DeltaTest::Stats do

  describe '.new' do

    it 'should initialize git instances for base_path and stats_path' do
      expect(DeltaTest::Git).to receive(:new).with(DeltaTest.config.base_path)
      expect(DeltaTest::Git).to receive(:new).with(DeltaTest.config.stats_path)
      expect {
        DeltaTest::Stats.new
      }.not_to raise_error
    end

  end

  let(:stats) { DeltaTest::Stats.new }

  let(:commit_hashes) do
    [
      '4444444444444444444444444444444444444444',
      '3333333333333333333333333333333333333333',
      '2222222222222222222222222222222222222222',
      '1111111111111111111111111111111111111111',
      '0000000000000000000000000000000000000000',
    ]
  end

  let(:files) do
    [
      '11/11111111111111111111111111111111111111/foo.txt',
      '11/11111111111111111111111111111111111111/1000000000-1000000-100.table',
      '33/33333333333333333333333333333333333333/bar.txt',
      '33/33333333333333333333333333333333333333/2000000000-1000000-100.table',
      '33/33333333333333333333333333333333333333/1000000000-1000000-100.table',
    ]
  end

  before do
    allow_any_instance_of(DeltaTest::Git).to receive(:ls_hashes)
      .with(DeltaTest.config.stats_life)
      .and_return(commit_hashes)
    allow_any_instance_of(DeltaTest::Git).to receive(:ls_files).and_return([])

    files.each do |file|
      file = DeltaTest.config.stats_path.join(file)
      FakeFS::FileSystem.add(file, FakeFS::FakeFile.new)
    end
  end

  describe '#base_commit' do

    it 'should return a base commit if exists' do
      allow_any_instance_of(DeltaTest::Git).to receive(:ls_files).and_return(files)
      expect(stats.base_commit).to eq('3333333333333333333333333333333333333333')
    end

    it 'should return nil if not exists' do
      expect(stats.base_commit).to be_nil
    end

  end

  describe '#commit_dir' do

    let(:commit_dir) { DeltaTest.config.stats_path.join('33/33333333333333333333333333333333333333') }

    it 'should return a file for the commit hash if base_commit exists' do
      allow_any_instance_of(DeltaTest::Git).to receive(:ls_files).and_return(files)
      expect(stats.commit_dir).to eq(commit_dir)
    end

    it 'should return nil if base_commit does not exist' do
      expect(stats.commit_dir).to be_nil
    end

  end

  describe '#table_file_path' do

    let(:table_file_path) { DeltaTest.config.stats_path.join('33/33333333333333333333333333333333333333/2000000000-1000000-100.table') }

    it 'should return a path of the newest table file' do
      allow_any_instance_of(DeltaTest::Git).to receive(:ls_files).and_return(files)
      expect(stats.table_file_path).to eq(table_file_path)
    end

    it 'should return nil if base_commit does not exist' do
      expect(stats.table_file_path).to be_nil
    end

  end

  context 'head: true' do

    let(:stats) { DeltaTest::Stats.new(head: true) }

    let(:head_commit) { '4444444444444444444444444444444444444444' }

    before do
      allow_any_instance_of(DeltaTest::Git).to receive(:rev_parse)
        .with('HEAD')
        .and_return(head_commit)
    end

    describe '#base_commit' do

      it 'should return a commit hash of HEAD' do
        expect(stats.base_commit).to eq(head_commit)
      end

    end

    describe '#table_file_path' do

      let(:table_file_path) { DeltaTest.config.stats_path.join('44/44444444444444444444444444444444444444/%s.table' % [DeltaTest.tester_id]) }

      it 'should return a path of the current tester_id' do
        expect(stats.table_file_path).to eq(table_file_path)
      end

    end

  end

end
