describe DeltaTest::Dependencies do

  it "should be a subclass of Set" do
    expect(DeltaTest::Dependencies).to be < Set
  end

  let(:dependencies) { DeltaTest::Dependencies.new }

  let(:base_path) { "/base_path" }
  let(:files) do
    [
      'foo/file_1.txt',
      'foo/file_2.txt',
      'foo/file_3.txt',
      'bar/file_4.txt',
    ]
  end

  before do
    DeltaTest.configure do |config|
      config.base_path = base_path
      config.files     = files
    end
  end

  describe "#regulate_file_name" do

    it "shoud return a relative path from `base_path`" do
      absolute_path = "%s/%s" % [base_path, files[0]]
      relative_path = Pathname.new(files[0])

      expect(dependencies.regulate_file_name(absolute_path)).to eq(relative_path)
    end

  end

end
