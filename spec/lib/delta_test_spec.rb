describe DeltaTest do

  describe "::configure" do

    it "should change option values inside a block" do
      expect {
        DeltaTest.configure do |config|
          expect(config).to be_a(DeltaTest::Configuration)
        end
      }.not_to raise_error
    end

  end

  describe "::active?" do

    it "should return a value of ACTIVE_FLAG" do
      active = (!ENV[DeltaTest::ACTIVE_FLAG].nil? && ENV[DeltaTest::ACTIVE_FLAG] =~ /0|false/i)
      expect(DeltaTest.active?).to be(active)
    end

  end

  describe "::activate!, ::deactivate!" do

    around do |example|
      active = DeltaTest.active?

      example.run

      if active
        DeltaTest.activate!
      else
        DeltaTest.deactivate!
      end
    end

    it "should change active flag" do
      DeltaTest.deactivate!
      expect(DeltaTest.active?).to be(false)
      DeltaTest.activate!
      expect(DeltaTest.active?).to be(true)
      DeltaTest.deactivate!
      expect(DeltaTest.active?).to be(false)
    end

  end

  describe "::regulate_filepath" do

    let(:path) { "/a/path" }

    it "shoud delegate to config" do
      expect(DeltaTest.config).to receive(:regulate_filepath).with(path)

      DeltaTest.regulate_filepath(path)
    end

  end

  describe "::find_file_upward" do

    let(:file) { FakeFS::FakeFile.new }
    let(:file_name) { "file" }

    it "should return a file path if a file is exist in the current directory" do
      pwd       = "/a/b/c/d"
      file_path = "/a/b/c/d/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it "should return a file path if a file is exist at the parent directory" do
      pwd       = "/a/b/c/d"
      file_path = "/a/b/c/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it "should return a file path if a file is exist at somewhere of parent directories" do
      pwd       = "/a/b/c/d"
      file_path = "/a/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it "should return nil if a file is not exist in any parent directories" do
      pwd       = "/a/b/c/d"
      file_path = "/abc/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(DeltaTest.find_file_upward(file_name)).to be_nil
      end
    end

    context "Multiple file names" do

      let(:file_2) { FakeFS::FakeFile.new }
      let(:file_name_2) { "file" }

      it "should return a file path if one of files is exist at somewhere of parent directories" do
        pwd       = "/a/b/c/d"
        file_path = "/a/#{file_name}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)

        Dir.chdir(pwd) do
          expect(DeltaTest.find_file_upward(file_name, file_name_2)).to eq(file_path)
        end
      end

      it "should return the first match if one of files is exist at somewhere of parent directories" do
        pwd         = "/a/b/c/d"
        file_path   = "/a/#{file_name}"
        file_path_2 = "/a/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(DeltaTest.find_file_upward(file_name, file_name_2)).to eq(file_path)
          expect(DeltaTest.find_file_upward(file_name_2, file_name)).to eq(file_path_2)
        end
      end

      it "should return nil if non of files is not exist in any parent directories" do
        pwd         = "/a/b/c/d"
        file_path   = "/abc/#{file_name}"
        file_path_2 = "/cba/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(DeltaTest.find_file_upward(file_name, file_name_2)).to be_nil
        end
      end

    end

  end

end
