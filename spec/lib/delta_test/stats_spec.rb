require 'delta_test/stats'
require 'delta_test/git'

describe DeltaTest::Stats do

  describe '::new' do

    it 'should initialize git instances for base_path and stats_path' do
      expect(DeltaTest::Git).to receive(:new).with(DeltaTest.config.base_path)
      expect(DeltaTest::Git).to receive(:new).with(DeltaTest.config.stats_path)
      expect {
        DeltaTest::Stats.new
      }.not_to raise_error
    end

  end

  describe '::find_file_by_commit' do

    let(:commit_hash)     { '0000000000000000000000000000000000000000' }
    let(:index_filename)  { '00/00000000000000000000000000000000000000' }
    let(:index_file_path) { DeltaTest.config.stats_path.join('indexes', index_filename) }

    it 'should return a file for the commit hash' do
      expect(DeltaTest::Stats.find_index_file_by_commit(commit_hash)).to eq(index_file_path)
    end

  end

  describe '#find_base_commit' do

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

    let(:indexes) do
      [
        '11/11111111111111111111111111111111111111',
        '33/33333333333333333333333333333333333333',
      ]
    end

    before do
      allow_any_instance_of(DeltaTest::Git).to receive(:ls_hashes)
        .with(DeltaTest.config.stats_life)
        .and_return(commit_hashes)

      allow_any_instance_of(DeltaTest::Git).to receive(:ls_files)
        .with(path: 'indexes')
        .and_return(indexes)
    end

    it 'should return the newest commit in the indexes' do
      expect(stats.find_base_commit).to eq('3333333333333333333333333333333333333333')
    end

  end

end
