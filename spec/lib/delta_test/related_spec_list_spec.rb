require 'delta_test/related_spec_list'

describe DeltaTest::RelatedSpecList do

  include_examples :defer_create_table_file

  let(:base) { 'master' }
  let(:head) { 'feature/foo' }
  let(:list) { DeltaTest::RelatedSpecList.new }

  let(:base_path) { '/base_path' }

  before do
    DeltaTest.configure do |config|
      config.base_path  = base_path
      config.table_file = table_file_path
    end
  end

  shared_examples :_mock_table_and_changed_files do

    let(:table) do
      table = DeltaTest::DependenciesTable.new

      table['spec/foo_spec.rb'] << 'lib/foo.rb'
      table['spec/bar_spec.rb'] << 'lib/bar.rb'
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

      allow(DeltaTest::Git).to receive(:git_repo?).and_return(true)
      allow(DeltaTest::Git).to receive(:changed_files).with(base, head).and_return(changed_files)
    end

  end

  describe '#load_table!' do

    it 'should raise an error if a table file is not exist' do
      expect {
        list.load_table!
      }.to raise_error(DeltaTest::TableNotFoundError)
    end

    it 'should load the table if exist' do
      table_file

      expect(list.table).to be_nil

      expect {
        list.load_table!
      }.not_to raise_error

      expect(list.table).to be_a(DeltaTest::DependenciesTable)
    end

  end

  describe '#retrive_changed_files!' do

    include_examples :_mock_table_and_changed_files

    it 'shoud raise an error if the directory is not managed by git' do
      allow(DeltaTest::Git).to receive(:git_repo?).and_return(false)

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

  describe '#related_spec_files' do

    include_examples :_mock_table_and_changed_files

    before do
      table_file
      list.load_table!
      list.retrive_changed_files!(base, head)
    end

    it 'should return a set of related spec files' do
      expect(list.related_spec_files).to eq(Set['spec/foo_spec.rb', 'spec/mixed_spec.rb'])
    end

  end

end
