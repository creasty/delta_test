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

  describe '::find_commit_dir' do

    let(:commit_hash) { '0000000000000000000000000000000000000000' }
    let(:commit_dir)  { DeltaTest.config.stats_path.join('00/00000000000000000000000000000000000000') }

    it 'should return a file for the commit hash' do
      expect(DeltaTest::Stats.find_commit_dir(commit_hash)).to eq(commit_dir)
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

    let(:commits) do
      [
        '11/11111111111111111111111111111111111111',
        '33/33333333333333333333333333333333333333',
      ]
    end

    before do
      allow_any_instance_of(DeltaTest::Git).to receive(:ls_hashes)
        .with(DeltaTest.config.stats_life)
        .and_return(commit_hashes)

      allow_any_instance_of(DeltaTest::Git).to receive(:ls_files).and_return(commits)
    end

    it 'should return the newest commit in the commits' do
      expect(stats.find_base_commit).to eq('3333333333333333333333333333333333333333')
    end

  end

end
