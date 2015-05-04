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

end
