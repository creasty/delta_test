require 'delta_test/utils'

describe DeltaTest::Utils do

  describe '.regulate_filepath' do

    let(:base_path) { Pathname.new('/base_path') }

    it 'shoud return a relative path from `base_path`' do
      absolute_path = Pathname.new('/base_path/foo/file_1.txt')
      relative_path = Pathname.new('foo/file_1.txt')

      expect(DeltaTest::Utils.regulate_filepath(absolute_path, base_path)).to eq(relative_path)
    end

    it 'shoud return a clean path' do
      absolute_path = Pathname.new('./foo/file_1.txt')
      relative_path = Pathname.new('foo/file_1.txt')

      expect(DeltaTest::Utils.regulate_filepath(absolute_path, base_path)).to eq(relative_path)
    end

    it 'shoud not raise an error and return the path when a path is not started with `base_path`' do
      path = Pathname.new('other/foo/file_1.txt')

      expect(DeltaTest::Utils.regulate_filepath(path, base_path)).to eq(path)
    end

  end

  describe '.find_file_upward' do

    let(:file)      { FakeFS::FakeFile.new }
    let(:file_name) { 'file' }

    it 'should return a file path if a file is exist in the current directory' do
      pwd       = '/a/b/c/d'
      file_path = "/a/b/c/d/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest::Utils.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return a file path if a file is exist at the parent directory' do
      pwd       = '/a/b/c/d'
      file_path = "/a/b/c/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest::Utils.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return a file path if a file is exist at somewhere of parent directories' do
      pwd       = '/a/b/c/d'
      file_path = "/a/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest::Utils.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return nil if a file is not exist in any parent directories' do
      pwd       = '/a/b/c/d'
      file_path = "/abc/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest::Utils.find_file_upward(file_name)).to be_nil
      end
    end

    context 'Multiple file names' do

      let(:file_2)      { FakeFS::FakeFile.new }
      let(:file_name_2) { 'file' }

      it 'should return a file path if one of files is exist at somewhere of parent directories' do
        pwd       = '/a/b/c/d'
        file_path = "/a/#{file_name}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)

        Dir.chdir(pwd) do
          expect(DeltaTest::Utils.find_file_upward(file_name, file_name_2)).to eq(file_path)
        end
      end

      it 'should return the first match if one of files is exist at somewhere of parent directories' do
        pwd         = '/a/b/c/d'
        file_path   = "/a/#{file_name}"
        file_path_2 = "/a/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(DeltaTest::Utils.find_file_upward(file_name, file_name_2)).to eq(file_path)
          expect(DeltaTest::Utils.find_file_upward(file_name_2, file_name)).to eq(file_path_2)
        end
      end

      it 'should return nil if non of files is not exist in any parent directories' do
        pwd         = '/a/b/c/d'
        file_path   = "/abc/#{file_name}"
        file_path_2 = "/cba/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(DeltaTest::Utils.find_file_upward(file_name, file_name_2)).to be_nil
        end
      end

    end

  end

  describe '.grep_pattern_to_regexp' do

    # private method
    let(:grep_pattern_to_regexp) { DeltaTest::Utils.method(:grep_pattern_to_regexp) }

    it 'should return a Regexp' do
      expect(grep_pattern_to_regexp.call('')).to be_a(Regexp)
    end

    it 'should wrap a pattern with ^ and $' do
      regexp = grep_pattern_to_regexp.call('aaa')

      expect(regexp).to be_a(Regexp)
      expect(regexp.source).to eq('^aaa$')
    end

    it 'should escape any special characters in a pattern' do
      regexp = grep_pattern_to_regexp.call('\?{}.')

      expect(regexp).to be_a(Regexp)
      expect(regexp.source).to eq('^\\\\\?\{\}\.$')
    end

    it 'should replace ** with super-directory wildcards' do
      regexp = grep_pattern_to_regexp.call('a/**')

      expect(regexp).to be_a(Regexp)
      expect(regexp.source).to eq('^a/.*$')
    end

    it 'should care about trailling slash when **/' do
      regexp = grep_pattern_to_regexp.call('a/**/path')

      expect(regexp).to be_a(Regexp)
      expect(regexp.source).to eq('^a/.*/?path$')
    end

    it 'should replace * with file/directory name wildcards' do
      regexp = grep_pattern_to_regexp.call('a/*_file')

      expect(regexp).to be_a(Regexp)
      expect(regexp.source).to eq('^a/[^/]*_file$')
    end

  end

  describe '.files_grep' do

    let(:files) do
      [
        '/0',
        '/a/b/c',
        '/a/b/c/d',
        '/a/b/c/d/e',
        '/x/y/z',
      ]
    end

    let(:patterns) do
      [
        '/a/**/*',
      ]
    end

    let(:exclude_patterns) do
      [
        '/a/**/e',
        '/x/y/*',
      ]
    end

    it 'should return the whole files when the patterns is an empty array' do
      expect(DeltaTest::Utils.files_grep(files, [])).to eq(files)
    end

    it 'should return the whole files when the exclude patterns is an empty array' do
      expect(DeltaTest::Utils.files_grep(files, [], [])).to eq(files)
    end

    it 'should return files only matched with the patterns' do
      matched_files = [
        '/a/b/c',
        '/a/b/c/d',
        '/a/b/c/d/e',
      ]

      expect(DeltaTest::Utils.files_grep(files, patterns)).to eq(matched_files)
    end

    it 'should return files not matched with the exclude patterns' do
      matched_files = [
        '/0',
        '/a/b/c',
        '/a/b/c/d',
      ]

      expect(DeltaTest::Utils.files_grep(files, [], exclude_patterns)).to eq(matched_files)
    end

    it 'should return files not matched with an union of patterns' do
      matched_files = [
        '/a/b/c',
        '/a/b/c/d',
      ]

      expect(DeltaTest::Utils.files_grep(files, patterns, exclude_patterns)).to eq(matched_files)
    end

  end

end
