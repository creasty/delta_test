require 'delta_test/dependencies_table'

describe DeltaTest::DependenciesTable do

  it 'should be a subclass of Hash' do
    expect(DeltaTest::DependenciesTable).to be < Hash
  end


  let(:table) { DeltaTest::DependenciesTable.new }

  describe '#[]' do

    it 'should initiate an empty set if not accessed before' do
      value = table[:foo]
      expect(value).to be_a(Set)
      expect(value).to be_empty
    end

    it 'should retain objects throughout accesses' do
      foo_1 = table[:foo].object_id
      foo_2 = table[:foo].object_id
      expect(foo_1).to eq(foo_2)
    end

  end

  describe '#add' do

    let(:spec_file) { 'spec/foo_spec.rb' }
    let(:base_path) { '/base_path' }

    let(:files) do
      ['foo/file_1.txt']
    end

    before do
      DeltaTest.configure do |config|
        config.base_path = base_path
        config.files     = files
      end
    end

    it 'should add a regulated file path' do
      table.add(spec_file, '/base_path/foo/file_1.txt')
      expect(table[spec_file]).to eq(Set[Pathname.new('foo/file_1.txt')])
    end

    it 'should add nothing if a file path is not included in `files` set' do
      table.add(spec_file, '/base_path/foo/file_2.txt')
      expect(table[spec_file]).to be_empty
    end

  end

  describe '#reverse_merge!' do

    let(:one_table)   { DeltaTest::DependenciesTable.new }
    let(:other_table) { DeltaTest::DependenciesTable.new }

    it 'should raise an error if other is not an instance of DependenciesTable' do
      expect {
        one_table.reverse_merge!({})
      }.to raise_error(TypeError)
    end

    it 'should merge other table into self' do
      one_table[:foo] << 1
      one_table[:foo] << 2
      one_table[:bar] << 3
      one_table[:one] << 4

      other_table[:foo] << 10
      other_table[:foo] << 20
      other_table[:bar] << 30
      other_table[:other] << 40

      expect {
        one_table.reverse_merge!(other_table)
      }.not_to raise_error

      expect(one_table.keys).to eq(one_table.keys | other_table.keys)
      expect(one_table[:foo]).to eq(Set[1, 2, 10, 20])
      expect(one_table[:bar]).to eq(Set[3, 30])
      expect(one_table[:one]).to eq(Set[4])
      expect(one_table[:other]).to eq(Set[40])
    end

  end

  describe '#without_default_proc' do

    it 'should reset default_proc temporary inside a block' do
      expect(table.default_proc).not_to be_nil
      table.without_default_proc do
        expect(table.default_proc).to be_nil
      end
      expect(table.default_proc).not_to be_nil
    end

  end

  describe '#cleanup!' do

    it 'should delete items where value is an empty set' do
      table[:foo]
      table[:bar] << 1
      expect(table.keys).to eq([:foo, :bar])
      table.cleanup!
      expect(table.keys).to eq([:bar])
    end

  end

  shared_examples :_create_table do

    include_examples :create_table_file

    let!(:table) do
      table = DeltaTest::DependenciesTable.new

      table[:foo] << 1
      table[:foo] << 2
      table[:bar] << 10
      table[:bar] << 20

      table
    end

  end

  describe '#dump' do

    include_examples :_create_table

    it 'should dump a table object to a file' do
      expect(table_file.content).to be_empty

      expect {
        table.dump(table_file_path)
      }.not_to raise_error

      expect(table_file.content).not_to be_empty
    end

  end

  describe '::load' do

    include_examples :_create_table

    it 'should restore a table object from a file' do
      table.dump(table_file_path)
      restored_table = nil
      expect {
        restored_table = DeltaTest::DependenciesTable.load(table_file_path)
      }.not_to raise_error
      expect(restored_table).to be_a(DeltaTest::DependenciesTable)
      expect(restored_table).to eq(table)
    end

  end

end
