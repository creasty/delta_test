require 'delta_test/git'

describe DeltaTest::Git do

  let(:out)            { '' }
  let(:success_status) { [out, '', double(success?: true)] }
  let(:error_status)   { ['', '', double(success?: false)] }

  let(:git) { DeltaTest::Git.new('.') }

  describe '::new' do

    it 'sholud execute commands in the specified directory' do
      dir = '/dir'
      git = DeltaTest::Git.new(dir)
      expect(git.dir).to be_a_kind_of(Pathname)
      expect(git.dir.to_s).to eq(dir)
    end

  end

  describe '#git_repo?' do

    let(:subcommand) { ['rev-parse --is-inside-work-tree'] }

    before do
      allow(git).to receive(:git_repo?).and_call_original
    end

    it 'should return false if `git` command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      result = nil

      expect {
        result = git.git_repo?
      }.not_to raise_error

      expect(result).to be(false)
    end

    it 'should return true exit code is 0' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.git_repo?).to be(true)
    end

    it 'should return false exit code not is 0' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.git_repo?).to be(false)
    end

  end

  describe '#root_dir' do

    let(:subcommand) { ['rev-parse --show-toplevel'] }
    let(:out)        { '/root/dir' }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.root_dir
      }.to raise_error
    end

    it 'should return a root directory path if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.root_dir).to eq(out)
    end

    it 'should return nil if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.root_dir).to be_nil
    end

  end

  describe '#rev_parse' do

    let(:rev)        { 'HEAD' }
    let(:subcommand) { ['rev-parse %s', rev] }
    let(:out)        { '818b60efa12b4bd99815e9b550185d1fb6244663' }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.rev_parse(rev)
      }.to raise_error
    end

    it 'should return a commit id if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.rev_parse(rev)).to eq(out)
    end

    it 'should return nil if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.rev_parse(rev)).to be_nil
    end

  end

  describe '#same_commit?' do

    let(:map) do
      {
        'master'      => '0000000000000000000000000000000000000000',
        'HEAD'        => '1111111111111111111111111111111111111111',
        'feature/foo' => '1111111111111111111111111111111111111111',
      }
    end

    before do
      map.each do |name, commit_id|
        allow(git).to receive(:rev_parse).with(name).and_return(commit_id)
      end
    end

    it 'should compare two names by thier commit ids' do
      names = map.values
      names.product(names).each do |r1, r2|
        expect(git).to receive(:rev_parse).with(r1).ordered
        expect(git).to receive(:rev_parse).with(r2).ordered

        is_same = (map[r1] == map[r2])

        expect(git.same_commit?(r1, r2)).to be(is_same)
      end
    end

  end

  describe '#ls_files' do

    let(:subcommand) { ['ls-files -z %s', '.'] }
    let(:out)        { "/a/file/1\x0/a/file/2\x0/a/file/3" }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.ls_files
      }.to raise_error
    end

    it 'should return an array if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.ls_files).to eq(out.split("\x0"))
    end

    it 'should return an empty array if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.ls_files).to eq([])
    end

  end

  describe '#changed_files' do

    let(:subcommand) { ['diff --name-only -z %s %s %s', 'master', 'HEAD', '.'] }
    let(:out)        { "/a/file/1\x0/a/file/2\x0/a/file/3" }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.changed_files
      }.to raise_error
    end

    it 'should return an array if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.changed_files).to eq(out.split("\x0"))
    end

    it 'should return an empty array if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.changed_files).to eq([])
    end

  end

  describe '#ls_hashes' do

    let(:subcommand) { [%q{log -z -n %d --format='%%H'}, 10] }
    let(:out)        { "0000\x01111\x02222" }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.ls_hashes(10)
      }.to raise_error
    end

    it 'should return an array if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.ls_hashes(10)).to eq(out.split("\x0"))
    end

    it 'should return an empty array if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.ls_hashes(10)).to eq([])
    end

  end

  describe '#remote_url' do

    let(:subcommand) { ['config --get remote.origin.url'] }
    let(:out)        { 'git@example.com:test/test.git' }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.remote_url
      }.to raise_error
    end

    it 'should return an url if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.remote_url).to eq(out)
    end

    it 'should return nil if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.remote_url).to be_nil
    end

  end

  describe '#has_remote?' do

    let(:subcommand) { ['config --get remote.origin.url'] }
    let(:out)        { 'git@example.com:test/test.git' }

    it 'should return false if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      res = nil

      expect {
        res = git.has_remote?
      }.not_to raise_error
      expect(res).to be(false)
    end

    it 'should return true if it has a remote origin' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.has_remote?).to be(true)
    end

    it 'should return false if not' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.has_remote?).to be(false)
    end

  end

  describe '#pull' do

    let(:subcommand) { ['pull origin master'] }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.pull
      }.to raise_error
    end

    it 'should return true if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.pull).to be(true)
    end

    it 'should return false if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.pull).to be(false)
    end

  end

  describe '#push' do

    let(:subcommand) { ['push origin master'] }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.push
      }.to raise_error
    end

    it 'should return true if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.push).to be(true)
    end

    it 'should return false if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.push).to be(false)
    end

  end

  describe '#add' do

    let(:subcommand) { ['add %s', '/a/path'] }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.add('/a/path')
      }.to raise_error
    end

    it 'should return true if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.add('/a/path')).to be(true)
    end

    it 'should return false if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.add('/a/path')).to be(false)
    end

  end

  describe '#commit' do

    let(:subcommand) { ['commit -m %s', 'message'] }

    it 'should raise an error if the command is not exist' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_raise

      expect {
        git.commit('message')
      }.to raise_error
    end

    it 'should return true if success' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(success_status)

      expect(git.commit('message')).to be(true)
    end

    it 'should return false if error' do
      expect(git).to receive(:exec).with(*subcommand).and_call_original
      allow(Open3).to receive(:capture3).and_return(error_status)

      expect(git.commit('message')).to be(false)
    end

  end

end
