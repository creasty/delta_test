require "delta_test/analyzer"

describe DeltaTest::Analyzer do

  let(:analyzer) { DeltaTest::Analyzer.new }

  after do
    RubyProf.stop if RubyProf.running?
  end

  describe "#new" do

    it "should initialize new instance" do
      expect { analyzer }.not_to raise_error
    end

  end

  describe "#start" do

    it "should start ruby-prof" do
      expect(RubyProf.running?).to be(false)

      expect {
        analyzer.start
      }.not_to raise_error

      expect(RubyProf.running?).to be(true)
    end

  end

  describe "#stop" do

    it "should not raise error if `start` is not yet called" do
      expect {
        analyzer.stop
      }.not_to raise_error
    end

    it "should set result" do
      analyzer.start

      expect(analyzer.result).to be_nil

      expect {
        analyzer.stop
      }.not_to raise_error

      expect(analyzer.result).not_to be_nil
    end

  end

  describe "#related_source_files" do

    it "should retrun nil if not yet started" do
      expect(analyzer.related_source_files).to be_nil
    end

    it "should return an empty set unless stop" do
      analyzer.start
      expect(analyzer.related_source_files).to be_empty
    end

    it "should return a set of source files after stopped" do
      analyzer.start
      analyzer.stop
      expect(analyzer.related_source_files).not_to be_empty
    end

    describe "Source files" do

      context "Instantiated class in a file" do

        it "should not include the file" do
          analyzer.start
          Sample::Alpha.new
          analyzer.stop
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/alpha.rb"))
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/beta.rb"))
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/gamma.rb"))
        end

      end

      context "Called some instance methods of a class in the file" do

        it "should include the file" do
          analyzer.start
          Sample::Alpha.new.alpha
          analyzer.stop
          expect(analyzer.related_source_files).to include(fixture_path("sample/alpha.rb"))
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/beta.rb"))
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/gamma.rb"))
        end

      end

      context "Called methods that uses extarnal classes" do

        it "should include a extarnal file" do
          analyzer.start
          Sample::Alpha.new.beta
          analyzer.stop
          expect(analyzer.related_source_files).to include(fixture_path("sample/alpha.rb"))
          expect(analyzer.related_source_files).to include(fixture_path("sample/beta.rb"))
          expect(analyzer.related_source_files).not_to include(fixture_path("sample/gamma.rb"))
        end

        it "should include extarnal files even if nested" do
          analyzer.start
          Sample::Alpha.new.beta_gamma
          analyzer.stop
          expect(analyzer.related_source_files).to include(fixture_path("sample/alpha.rb"))
          expect(analyzer.related_source_files).to include(fixture_path("sample/beta.rb"))
          expect(analyzer.related_source_files).to include(fixture_path("sample/gamma.rb"))
        end

      end

    end

  end

end
