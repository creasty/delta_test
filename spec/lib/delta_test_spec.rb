describe DeltaTest do

  describe "::configure" do

    it "should change option values inside a block" do
      expect {
        DeltaTest.configure do |config|
          expect(config).to be_a(DeltaTest::Configuration)
        end
      }.not_to raise_error
    end

    it "should call `precalculate!` after the block" do
      dummy = double
      allow(dummy).to receive(:not_yet_called)
      allow(dummy).to receive(:already_called)

      expect(dummy).to receive(:not_yet_called).with(no_args).once.ordered
      expect(DeltaTest.config).to receive(:precalculate!).with(no_args).once.ordered
      expect(dummy).to receive(:already_called).with(no_args).once.ordered

      DeltaTest.configure do |config|
        dummy.not_yet_called
      end
      dummy.already_called
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

end
