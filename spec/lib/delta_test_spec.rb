describe DeltaTest do

  describe "::configure" do

    it "should change option values inside a block" do
      expect {
        DeltaTest.configure do |config|
          expect(config).to be_a(DeltaTest::Configuration)
        end
      }
    end

  end

  describe "::regulate_filepath" do

    let(:base_path) { "/base_path" }

    before do
      DeltaTest.configure do |config|
        config.base_path = base_path
      end
    end

    it "shoud return a relative path from `base_path`" do
      absolute_path = Pathname.new("/base_path/foo/file_1.txt")
      relative_path = Pathname.new("foo/file_1.txt")

      expect(DeltaTest.regulate_filepath(absolute_path)).to eq(relative_path)
    end

    it "shoud return a clean path" do
      absolute_path = Pathname.new("./foo/file_1.txt")
      relative_path = Pathname.new("foo/file_1.txt")

      expect(DeltaTest.regulate_filepath(absolute_path)).to eq(relative_path)
    end

    it "shoud not raise an error and return the path when a path is not started with `base_path`" do
      path = Pathname.new("other/foo/file_1.txt")

      expect(DeltaTest.regulate_filepath(path)).to eq(path)
    end

  end

end
