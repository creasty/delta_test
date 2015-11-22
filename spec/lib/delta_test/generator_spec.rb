require 'delta_test/generator'

describe DeltaTest::Generator do

  include_examples :create_table_file

  let(:base_path) { Pathname.new(File.expand_path('../../../fixtures', __FILE__)) }

  let(:spec_file)   { 'foo/spec_file.rb' }
  let(:spec_file_2) { 'foo/spec_file_2.rb' }

  let(:files) do
    [
      'sample/alpha.rb',
      'sample/beta.rb',
      # 'sample/gamma.rb',  # intentionally omitted
    ]
  end

  let(:generator) { DeltaTest::Generator.new }

  before do
    DeltaTest.configure do |config|
      config.base_path        = base_path
      config.files            = files
      config.stats_repository = 'git@example.com:test/test.git'
      config.stats_path       = stats_path
    end

    DeltaTest.active = true
  end

  after do
    DeltaTest.active = false
    DeltaTest::Profiler.clean!
  end

  describe '#setup!' do

    it 'should setup a generator' do
      expect {
        generator.setup!
      }.not_to raise_error

      expect(generator).to be_respond_to(:table)
      expect(generator.table).to be_a(DeltaTest::DependenciesTable)
    end

  end

  describe '#start!' do

    before do
      generator.setup!
    end

    it 'should start the profiler' do
      expect(DeltaTest::Profiler.running?).to be(false)

      expect {
        generator.start!(spec_file)
      }.not_to raise_error

      expect(DeltaTest::Profiler.running?).to be(true)
    end

    describe '#current_spec_file' do

      it 'should be set' do
        expect(generator.current_spec_file).to be_nil
        generator.start!(spec_file)
        expect(generator.current_spec_file).to eq(spec_file)
      end

      it 'should be regulated' do
        expect(generator.current_spec_file).to be_nil
        generator.start!('./%s' % spec_file)
        expect(generator.current_spec_file).to eq(spec_file)
      end

    end

  end

  describe '#stop!' do

    before do
      generator.setup!
    end

    it 'should stop the profiler' do
      expect(DeltaTest::Profiler.running?).to be(false)
      generator.start!(spec_file)
      expect(DeltaTest::Profiler.running?).to be(true)
      generator.stop!
      expect(DeltaTest::Profiler.running?).to be(false)
    end

    it 'should unset current_spec_file' do
      expect(generator.current_spec_file).to be_nil
      generator.start!(spec_file)
      expect(generator.current_spec_file).to eq(spec_file)
      generator.stop!
      expect(generator.current_spec_file).to be_nil
    end

  end

  describe '#table' do

    before do
      generator.setup!
    end

    it 'should return a set of source files' do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.alpha
      generator.stop!

      expect(generator.table.keys).to eq([spec_file])
      expect(generator.table[spec_file]).to include(Pathname.new('sample/alpha.rb'))
    end

    it 'should return a set of source files for every spec files' do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.alpha
      generator.stop!

      generator.start!(spec_file_2)
      Sample::Beta.new.beta
      generator.stop!

      expect(generator.table.keys).to eq([spec_file, spec_file_2])
      expect(generator.table[spec_file]).to include(Pathname.new('sample/alpha.rb'))
      expect(generator.table[spec_file_2]).to include(Pathname.new('sample/beta.rb'))
    end

    it 'should not include paths not included in `files`' do
      expect(generator.table).to be_empty

      generator.start!(spec_file)
      Sample::Alpha.new.beta_gamma
      generator.stop!

      expect(generator.table.keys).to eq([spec_file])
      expect(generator.table[spec_file]).to include(Pathname.new('sample/alpha.rb'))
      expect(generator.table[spec_file]).to include(Pathname.new('sample/beta.rb'))
      expect(generator.table[spec_file]).not_to include(Pathname.new('sample/gamma.rb'))
    end

  end

  describe '#teardown!' do

    context 'When not `setup!` is called yet' do

      it 'should do nothing' do
        expect {
          generator.teardown!
        }.not_to raise_error
      end

    end

    context 'When `setup!` is called' do

      before do
        generator.setup!
      end

      it 'should stop the profiler if running' do
        expect(DeltaTest::Profiler.running?).to be(false)
        generator.start!(spec_file)
        expect(DeltaTest::Profiler.running?).to be(true)
        generator.teardown!
        expect(DeltaTest::Profiler.running?).to be(false)
      end

      it 'should save the table into a file' do
        expect(generator.table).to be_empty

        generator.start!(spec_file)
        Sample::Alpha.new.beta_gamma
        generator.stop!

        expect(generator.table).not_to be_empty
        expect(tmp_stats_file.content).to be_empty

        generator.teardown!

        expect(tmp_stats_file.content).not_to be_empty
      end

    end

  end

  describe '#hook_on_exit' do

    before do
      allow(Kernel).to receive(:at_exit).and_return(nil)
    end

    it 'should call at_exit' do
      # FIXME
      # expect(Kernel).to receive(:at_exit)

      expect {
        generator.hook_on_exit
      }.not_to raise_error
    end

  end

end
