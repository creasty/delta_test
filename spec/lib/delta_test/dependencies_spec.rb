require "delta_test/dependencies"

describe DeltaTest::Dependencies do

  it "should be a subclass of Set" do
    expect(DeltaTest::Dependencies).to be < Set
  end

  let(:dependencies) { DeltaTest::Dependencies.new }

  let(:base_path) { "/base_path" }
  let(:files) do
    ["foo/file_1.txt"]
  end

  before do
    DeltaTest.configure do |config|
      config.base_path = base_path
      config.files     = files
    end
  end

  describe "#add" do

    it "should add a regulated file path" do
      dependencies.add("/base_path/foo/file_1.txt")
      expect(dependencies.to_a).to eq([Pathname.new("foo/file_1.txt")])
    end

    it "should add nothing if a file path is not included in `files` set" do
      dependencies.add("/base_path/foo/file_2.txt")
      expect(dependencies).to be_empty
    end

  end

end
