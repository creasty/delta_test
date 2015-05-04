describe DeltaTest::Generator do

  include FakeFS::SpecHelpers

  let(:base_path) { Pathname.new(File.expand_path('../../../supports', __FILE__)) }
  let(:table_file_path) { Pathname.new("table_file_path") }

  let(:spec_file) { "foo/spec_file.rb" }
  let(:spec_file_2) { "foo/spec_file_2.rb" }

  let(:files) do
    [
      "sample/alpha.rb",
      "sample/beta.rb",
      # "sample/gamma.rb",  # intentionally omitted
    ]
  end

  let!(:table_file) do
    file = FakeFS::FakeFile.new
    FakeFS::FileSystem.add(base_path.join(table_file_path), file)
  end

  let(:generator) { DeltaTest::Generator.new }

  before do
    DeltaTest.configure do |config|
      config.base_path  = base_path
      config.table_file = table_file_path
      config.files      = files
    end

    DeltaTest.activate!
  end

  after do
    DeltaTest.deactivate!
    RubyProf.stop if RubyProf.running?
  end

  describe "#setup!" do

    it "should setup a generator" do
      expect {
        generator.setup!(false)  # disable tearadown
      }.not_to raise_error

      expect(generator).to be_respond_to(:table)
      expect(generator.table).to be_a(DeltaTest::DependenciesTable)
    end

  end

  describe "#start!" do

    before do
      generator.setup!(false)  # disable tearadown
    end

    it "should start ruby-prof" do
      expect(RubyProf.running?).to be(false)

      expect {
        generator.start!(spec_file)
      }.not_to raise_error

      expect(RubyProf.running?).to be(true)
    end

    it "should set current_spec_file" do
      expect(generator.current_spec_file).to be_nil
      generator.start!(spec_file)
      expect(generator.current_spec_file).to eq(spec_file)
    end

  end

  describe "#stop!" do

    before do
      generator.setup!(false)  # disable tearadown
    end

    it "should stop ruby-prof" do
      expect(RubyProf.running?).to be(false)
      generator.start!(spec_file)
      expect(RubyProf.running?).to be(true)
      generator.stop!
      expect(RubyProf.running?).to be(false)
    end

    it "should unset current_spec_file" do
      expect(generator.current_spec_file).to be_nil
      generator.start!(spec_file)
      expect(generator.current_spec_file).to eq(spec_file)
      generator.stop!
      expect(generator.current_spec_file).to be_nil
    end

  end

  describe "#table" do

    before do
      generator.setup!(false)  # disable tearadown
    end

    it "should return a set of source files" do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.alpha
      generator.stop!

      expect(generator.table.keys).to eq([spec_file])
      expect(generator.table[spec_file]).to include(Pathname.new("sample/alpha.rb"))
    end

    it "should return a set of source files for every spec files" do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.alpha
      generator.stop!

      generator.start!(spec_file_2)
      Sample::Beta.new.beta
      generator.stop!

      expect(generator.table.keys).to eq([spec_file, spec_file_2])
      expect(generator.table[spec_file]).to include(Pathname.new("sample/alpha.rb"))
      expect(generator.table[spec_file_2]).to include(Pathname.new("sample/beta.rb"))
    end

    it "should not include paths not included in `files`" do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.beta_gamma
      generator.stop!

      expect(generator.table.keys).to eq([spec_file])
      expect(generator.table[spec_file]).to include(Pathname.new("sample/alpha.rb"))
      expect(generator.table[spec_file]).to include(Pathname.new("sample/beta.rb"))
      expect(generator.table[spec_file]).not_to include(Pathname.new("sample/gamma.rb"))
    end

  end

  describe "#teardown!" do

    context "When not `setup!` is called yet" do

      it "should do nothing" do
        expect {
          generator.teardown!
        }.not_to raise_error
      end

    end

    context "When `setup!` is called" do

      before do
        generator.setup!(false)  # disable tearadown
      end

      it "should stop ruby-prof if running" do
        expect(RubyProf.running?).to be(false)
        generator.start!(spec_file)
        expect(RubyProf.running?).to be(true)
        generator.teardown!
        expect(RubyProf.running?).to be(false)
      end

      it "should save the table into a file" do
        expect(generator.table).to be_empty

        generator.start!(spec_file)
        Sample::Alpha.new.beta_gamma
        generator.stop!

        expect(generator.table).not_to be_empty
        expect(table_file.content).to be_empty

        generator.teardown!

        expect(table_file.content).not_to be_empty
      end

    end

  end

end
