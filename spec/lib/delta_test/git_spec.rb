require 'delta_test/git'

describe DeltaTest::Git do

  let(:out)            { '' }
  let(:success_status) { [out, '', double(success?: true)] }
  let(:error_status)   { ['', '', double(success?: false)] }

  describe '::git_repo?' do

    let(:command) { %q{git rev-parse --is-inside-work-tree} }

    it 'should return false if `git` command is not exist' do
      allow(Open3).to receive(:capture3).with(command).and_raise

      result = nil

      expect {
        result = DeltaTest::Git.git_repo?
      }.not_to raise_error

      expect(result).to be(false)
    end

    it 'should return true exit code is 0' do
      allow(Open3).to receive(:capture3).with(command).and_return(success_status)

      expect(DeltaTest::Git.git_repo?).to be(true)
    end

    it 'should return false exit code not is 0' do
      allow(Open3).to receive(:capture3).with(command).and_return(error_status)

      expect(DeltaTest::Git.git_repo?).to be(false)
    end

  end

  describe '::root_dir' do

    let(:command) { %q{git rev-parse --show-toplevel} }
    let(:out)     { '/root/dir' }

    it 'should raise an error if the command is not exist' do
      allow(Open3).to receive(:capture3).with(command).and_raise

      expect {
        DeltaTest::Git.root_dir
      }.to raise_error
    end

    it 'should return a root directory path if success' do
      allow(Open3).to receive(:capture3).with(command).and_return(success_status)

      expect(DeltaTest::Git.root_dir).to eq(out)
    end

    it 'should return nil if error' do
      allow(Open3).to receive(:capture3).with(command).and_return(error_status)

      expect(DeltaTest::Git.root_dir).to be_nil
    end

  end

  describe '::ls_files' do

    let(:command) { %q{git ls-files -z} }
    let(:out)     { "/a/file/1\x0/a/file/2\x0/a/file/3" }

    it 'should raise an error if the command is not exist' do
      allow(Open3).to receive(:capture3).with(command).and_raise

      expect {
        DeltaTest::Git.ls_files
      }.to raise_error
    end

    it 'should return an array if success' do
      allow(Open3).to receive(:capture3).with(command).and_return(success_status)

      expect(DeltaTest::Git.ls_files).to eq(out.split("\x0"))
    end

    it 'should return an empty array if error' do
      allow(Open3).to receive(:capture3).with(command).and_return(error_status)

      expect(DeltaTest::Git.ls_files).to eq([])
    end

  end

  describe '::changed_files' do

    let(:command) { %q{git --no-pager diff --name-only -z master HEAD} }
    let(:out)     { "/a/file/1\x0/a/file/2\x0/a/file/3" }

    it 'should raise an error if the command is not exist' do
      allow(Open3).to receive(:capture3).with(command).and_raise

      expect {
        DeltaTest::Git.changed_files
      }.to raise_error
    end

    it 'should return an array if success' do
      allow(Open3).to receive(:capture3).with(command).and_return(success_status)

      expect(DeltaTest::Git.changed_files).to eq(out.split("\x0"))
    end

    it 'should return an empty array if error' do
      allow(Open3).to receive(:capture3).with(command).and_return(error_status)

      expect(DeltaTest::Git.changed_files).to eq([])
    end

  end

end
