require 'delta_test/profiler'

describe DeltaTest::Profiler do

  let(:profiler) { DeltaTest::Profiler.new }

  after do
    DeltaTest::Profiler.clean!
  end

  describe '#new' do

    it 'should initialize new instance' do
      expect { profiler }.not_to raise_error
    end

  end

  describe '#start' do

    it 'should start profiler' do
      expect(profiler.running?).to be(false)

      expect {
        profiler.start
      }.not_to raise_error

      expect(profiler.running?).to be(true)
    end

  end

  describe '#stop' do

    it 'should not raise error if `start` is not yet called' do
      expect {
        profiler.stop
      }.not_to raise_error
    end

    it 'should set result' do
      expect(profiler.result).to be_a(Array)
      expect(profiler.result).to be_empty

      profiler.start

      expect {
        profiler.stop
      }.not_to raise_error

      expect(profiler.result).to be_a(Array)
      expect(profiler.result).not_to be_empty
    end

  end

  describe '#related_source_files' do

    it 'should retrun an empty set if not yet started' do
      files = profiler.related_source_files
      expect(files).to be_a(Set)
      expect(files).to be_empty
    end

    it 'should return nil if running' do
      profiler.start

      files = profiler.related_source_files
      expect(files).to be_nil
    end

    it 'should return a set of source files' do
      profiler.start
      profiler.stop
      files = profiler.related_source_files
      expect(files).to be_a(Set)
      expect(files).not_to be_empty
    end

    describe 'Source files' do

      context 'Instantiated class in a file' do

        it 'should not include the file' do
          profiler.start
          Sample::Alpha.new
          profiler.stop
          expect(profiler.related_source_files).not_to include(fixture_path('sample/alpha.rb'))
          expect(profiler.related_source_files).not_to include(fixture_path('sample/beta.rb'))
          expect(profiler.related_source_files).not_to include(fixture_path('sample/gamma.rb'))
        end

      end

      context 'Called some instance methods of a class in the file' do

        it 'should include the file' do
          profiler.start
          Sample::Alpha.new.alpha
          profiler.stop
          expect(profiler.related_source_files).to include(fixture_path('sample/alpha.rb'))
          expect(profiler.related_source_files).not_to include(fixture_path('sample/beta.rb'))
          expect(profiler.related_source_files).not_to include(fixture_path('sample/gamma.rb'))
        end

      end

      context 'Called methods that uses extarnal classes' do

        it 'should include a extarnal file' do
          profiler.start
          Sample::Alpha.new.beta
          profiler.stop
          expect(profiler.related_source_files).to include(fixture_path('sample/alpha.rb'))
          expect(profiler.related_source_files).to include(fixture_path('sample/beta.rb'))
          expect(profiler.related_source_files).not_to include(fixture_path('sample/gamma.rb'))
        end

        it 'should include extarnal files even if nested' do
          profiler.start
          Sample::Alpha.new.beta_gamma
          profiler.stop
          expect(profiler.related_source_files).to include(fixture_path('sample/alpha.rb'))
          expect(profiler.related_source_files).to include(fixture_path('sample/beta.rb'))
          expect(profiler.related_source_files).to include(fixture_path('sample/gamma.rb'))
        end

      end

    end

  end

end
