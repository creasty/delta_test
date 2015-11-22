require 'delta_test/related_spec_list'

describe DeltaTest::RelatedSpecList do

  include_examples :defer_create_table_file

  let(:base) { 'master' }
  let(:head) { 'feature/foo' }
  let(:list) { DeltaTest::RelatedSpecList.new }

  let(:base_path) { '/base_path' }

  before do
    DeltaTest.configure do |config|
      config.base_path = base_path
    end
  end

  shared_examples :_mock_table_and_changed_files do

    let(:table) do
      table = DeltaTest::DependenciesTable.new

      table['spec/foo_spec.rb'] << 'lib/foo.rb'
      table['spec/bar_spec.rb'] << 'lib/bar.rb'
      table['spec/baz_spec.rb'] << 'lib/baz.rb'
      table['spec/other_spec.rb']
      table['spec/mixed_spec.rb'] << 'lib/foo.rb'
      table['spec/mixed_spec.rb'] << 'lib/bar.rb'

      table
    end

    let(:changed_files) do
      [
        'lib/foo.rb',
      ]
    end

    before do
      allow(DeltaTest::DependenciesTable).to receive(:load).with(Pathname.new(table_file_path)).and_return(table)

      allow(list.git).to receive(:git_repo?).and_return(true)
      allow(list.git).to receive(:changed_files).with(base, head).and_return(changed_files)
    end

  end

  describe '#load_table!' do

    it 'should raise an error if a table file is not exist' do
      expect {
        list.load_table!(table_file_path)
      }.to raise_error(DeltaTest::TableNotFoundError)
    end

    it 'should load the table if exist' do
      table_file

      expect(list.table).to be_nil

      expect {
        list.load_table!(table_file_path)
      }.not_to raise_error

      expect(list.table).to be_a(DeltaTest::DependenciesTable)
    end

  end

  describe '#retrive_changed_files!' do

    include_examples :_mock_table_and_changed_files

    it 'shoud raise an error if the directory is not managed by git' do
      allow(list.git).to receive(:git_repo?).and_return(false)

      expect {
        list.retrive_changed_files!(base, head)
      }.to raise_error(DeltaTest::NotInGitRepositoryError)
    end

    it 'shoud retrive a list of changed files' do
      expect(list.changed_files).to be_nil

      list.retrive_changed_files!(base, head)

      expect(list.changed_files).to be_a(Array)
      expect(list.changed_files).not_to be_empty
    end

  end

  context 'Related spec files' do

    include_examples :_mock_table_and_changed_files

    before do
      table_file
      list.load_table!(table_file_path)
      list.retrive_changed_files!(base, head)
    end

    describe '#dependents' do

      describe 'Dependents' do

        let(:dependents) do
          Set[
            'spec/foo_spec.rb',
            'spec/mixed_spec.rb',
          ]
        end

        it 'should be included' do
          expect(list.dependents).to eq(dependents)
        end

      end

      describe 'Modified spec files' do

        let(:changed_files) do
          [
            'lib/foo.rb',
            'spec/baz_spec.rb',
          ]
        end

        let(:dependents) do
          Set[
            'spec/foo_spec.rb',
            'spec/mixed_spec.rb',
            'spec/baz_spec.rb',
          ]
        end

        it 'should be included' do
          expect(list.dependents).to eq(dependents)
        end

      end

    end

    describe '#customs' do

      let(:custom_mappings) do
        {
          'spec/other_spec.rb' => [
            'config/locales/**/*.yml',
          ]
        }
      end

      let(:changed_files) do
        [
          'config/locales/something/en.yml',
        ]
      end

      let(:customs) do
        Set[
          'spec/other_spec.rb',
        ]
      end

      before do
        DeltaTest.configure do |config|
          config.custom_mappings = custom_mappings
        end
      end

      after do
        DeltaTest.configure do |config|
          config.custom_mappings = {}
        end
      end

      it 'should include custom mapped files' do
        expect(list.customs).to eq(customs)
      end

    end

    describe '#full_tests?' do

      context 'No file in full test patterns is changed' do

        let(:changed_files) do
          [
            'spec/other_spec.rb',
          ]
        end

        it 'should return false' do
          expect(list.full_tests?).to be(false)
        end

      end

      context 'No file in full test patterns is changed' do

        let(:full_test_patterns) do
          [
            'spec/other_spec.rb',
          ]
        end

        let(:changed_files) do
          [
            'spec/other_spec.rb',
          ]
        end

        before do
          DeltaTest.configure do |config|
            config.full_test_patterns = full_test_patterns
          end
        end

        after do
          DeltaTest.configure do |config|
            config.full_test_patterns = []
          end
        end

        it 'should return true' do
          expect(list.full_tests?).to be(true)
        end

      end

    end

    describe '#full' do

      let(:full_spec_files) do
        Set[
          'spec/foo_spec.rb',
          'spec/bar_spec.rb',
          'spec/baz_spec.rb',
          'spec/other_spec.rb',
          'spec/mixed_spec.rb',
        ]
      end

      it 'should return full spec files in the table' do
        expect(list.full).to eq(full_spec_files)
      end

    end

    describe '#related_spec_files' do

      context 'If `full_tests?` is true' do

        before do
          allow(list).to receive(:full_tests?).and_return(true)
        end

        it 'should return full spec files' do
          expect(list).to receive(:full)
          expect(list).not_to receive(:dependents)
          expect(list).not_to receive(:customs)

          list.related_spec_files
        end

      end

      context 'If `full_tests?` is false' do

        let(:dependents) { Set['dependent_1'] }
        let(:customs)    { Set['custom_1'] }

        before do
          allow(list).to receive(:full_tests?).and_return(false)
          allow(list).to receive(:dependents).and_return(dependents)
          allow(list).to receive(:customs).and_return(customs)
        end

        it 'should return a union set of dependents and custom' do
          expect(list).not_to receive(:full)
          expect(list).to receive(:dependents)
          expect(list).to receive(:customs)

          expect(list.related_spec_files).to eq(dependents | customs)
        end

      end

    end

  end

end
