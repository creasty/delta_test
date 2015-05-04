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
    let(:files) do
      [
        "foo/file_1.txt",
        "foo/file_2.txt",
        "foo/file_3.txt",
        "bar/file_4.txt",
      ]
    end

    before do
      DeltaTest.configure do |config|
        config.base_path = base_path
        config.files     = files
      end
    end

    it "shoud return a relative path from `base_path`" do
      absolute_path = "%s/%s" % [base_path, files[0]]
      relative_path = Pathname.new(files[0])

      expect(DeltaTest.regulate_filepath(absolute_path)).to eq(relative_path)
    end

  end

end
