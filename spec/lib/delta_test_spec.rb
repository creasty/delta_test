describe DeltaTest do

  describe '.configure' do

    it 'should change option values inside a block' do
      expect {
        DeltaTest.configure do |config|
          expect(config).to be_a(DeltaTest::Configuration)
        end
      }.not_to raise_error
    end

  end

  describe '.active?' do

    context 'Initial' do

      before do
        DeltaTest.active = nil
      end

      it 'should return true if ACTIVE_FLAG env variable is truly' do
        allow(ENV).to receive(:[]).with(DeltaTest::ACTIVE_FLAG).and_return('true')
        expect(DeltaTest.active?).to be(true)
      end

      it 'should return fales if ACTIVE_FLAG env variable is falsy' do
        allow(ENV).to receive(:[]).with(DeltaTest::ACTIVE_FLAG).and_return('false')
        expect(DeltaTest.active?).to be(false)
      end

    end

    context 'Manual' do

      it 'should return true if it is set to true manually' do
        DeltaTest.active = true
        expect(DeltaTest.active?).to be(true)
      end

      it 'should return false if it is set to false manually' do
        DeltaTest.active = false
        expect(DeltaTest.active?).to be(false)
      end

    end

  end

  describe '.verbose?' do

    context 'Initial' do

      before do
        DeltaTest.verbose = nil
      end

      it 'should return true if VERBOSE_FLAG env variable is truly' do
        allow(ENV).to receive(:[]).with(DeltaTest::VERBOSE_FLAG).and_return('true')
        expect(DeltaTest.verbose?).to be(true)
      end

      it 'should return fales if VERBOSE_FLAG env variable is falsy' do
        allow(ENV).to receive(:[]).with(DeltaTest::VERBOSE_FLAG).and_return('false')
        expect(DeltaTest.verbose?).to be(false)
      end

    end

    context 'Manual' do

      it 'should return true if it is set to true manually' do
        DeltaTest.verbose = true
        expect(DeltaTest.verbose?).to be(true)
      end

      it 'should return false if it is set to false manually' do
        DeltaTest.verbose = false
        expect(DeltaTest.verbose?).to be(false)
      end

    end

  end

  describe '.log' do

    context 'In verbose mode' do

      before do
        DeltaTest.verbose = true
      end

      it 'should print logs' do
        expect {
          DeltaTest.log('hello, world')
        }.to output(/hello, world/).to_stdout
      end

    end

    context 'Not in verbose mode' do

      before do
        DeltaTest.verbose = false
      end

      it 'should not print any logs' do
        expect {
          DeltaTest.log('hello, world')
        }.not_to output.to_stdout
      end

    end

  end

  describe '.tester_id' do

    it 'should return an unique id for process' do
      expect(DeltaTest.tester_id).to be_a(String)
      expect(DeltaTest.tester_id).to match(/\A\d+-\d+-\d+\z/)
    end

  end

end
