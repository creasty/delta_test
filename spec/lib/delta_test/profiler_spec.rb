require 'delta_test/profiler'

describe DeltaTest::Profiler do

  after do
    DeltaTest::Profiler.clean!
  end

  describe '::start!' do

    it 'should start profiler' do
      expect(DeltaTest::Profiler.running?).to be(false)

      expect {
        DeltaTest::Profiler.start!
      }.not_to raise_error

      expect(DeltaTest::Profiler.running?).to be(true)
    end

  end

  describe '::stop!' do

    it 'should not raise error if the profiler not yet started' do
      expect {
        DeltaTest::Profiler.stop!
      }.not_to raise_error
    end

    it 'should set result' do
      expect(DeltaTest::Profiler.last_result).to be_a(Array)

      DeltaTest::Profiler.start!

      expect {
        DeltaTest::Profiler.stop!
      }.not_to raise_error

      expect(DeltaTest::Profiler.last_result).to be_a(Array)
      expect(DeltaTest::Profiler.last_result).not_to be_empty
    end

  end

  describe '::last_result' do

    it 'should retrun an array if not yet started' do
      files = DeltaTest::Profiler.last_result
      expect(files).to be_a(Array)
    end

    it 'should return nil if running' do
      DeltaTest::Profiler.start!

      files = DeltaTest::Profiler.last_result
      expect(files).to be_nil
    end

    it 'should return an array of source files' do
      DeltaTest::Profiler.start!
      DeltaTest::Profiler.stop!
      files = DeltaTest::Profiler.last_result
      expect(files).to be_a(Array)
    end

    describe 'Source files' do

      context 'Instantiated class in a file' do

        it 'should not include the file' do
          DeltaTest::Profiler.start!
          Sample::Alpha.new
          DeltaTest::Profiler.stop!
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/alpha.rb'))
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/beta.rb'))
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/gamma.rb'))
        end

      end

      context 'Called some instance methods of a class in the file' do

        it 'should include the file' do
          DeltaTest::Profiler.start!
          Sample::Alpha.new.alpha
          DeltaTest::Profiler.stop!
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/alpha.rb'))
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/beta.rb'))
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/gamma.rb'))
        end

      end

      context 'Called methods that uses extarnal classes' do

        it 'should include a extarnal file' do
          DeltaTest::Profiler.start!
          Sample::Alpha.new.beta
          DeltaTest::Profiler.stop!
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/alpha.rb'))
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/beta.rb'))
          expect(DeltaTest::Profiler.last_result).not_to include(fixture_path('sample/gamma.rb'))
        end

        it 'should include extarnal files even if nested' do
          DeltaTest::Profiler.start!
          Sample::Alpha.new.beta_gamma
          DeltaTest::Profiler.stop!
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/alpha.rb'))
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/beta.rb'))
          expect(DeltaTest::Profiler.last_result).to include(fixture_path('sample/gamma.rb'))
        end

      end

    end

  end

end
