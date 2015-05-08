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

end
