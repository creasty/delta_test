require "delta_test/spec_helpers"

describe DeltaTest::SpecHelpers do

  before do
    @rspec_example_group = Class.new do
      class << self
        def before(_)
          yield if block_given?
        end

        def after(_)
          yield if block_given?
        end

        def metadata
          { file_path: "spec/foo/bar.rb" }
        end
      end
    end

    allow(DeltaTest).to receive(:active?).and_return(false)
  end

  it "should define a global generator" do
    expect(defined?($delta_test_generator)).not_to be(false)
  end

  describe "when extending" do

    context "before :all" do

      it "should call it" do
        expect(@rspec_example_group).to receive(:before).with(:context)
        @rspec_example_group.extend DeltaTest::SpecHelpers
      end

      it "should start the generator" do
        expect($delta_test_generator).to receive(:start!).with("spec/foo/bar.rb")
        @rspec_example_group.extend DeltaTest::SpecHelpers
      end

    end

    context "after :all" do

      it "should call it" do
        expect(@rspec_example_group).to receive(:after).with(:context)
        @rspec_example_group.extend DeltaTest::SpecHelpers
      end

      it "should stop the generator" do
        expect($delta_test_generator).to receive(:stop!)
        @rspec_example_group.extend DeltaTest::SpecHelpers
      end

    end

  end

  describe "when including" do

    it "should call it" do
      expect(@rspec_example_group).to receive(:before)
      @rspec_example_group.class_eval do
        include DeltaTest::SpecHelpers
      end
    end

  end

end
