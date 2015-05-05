require "delta_test/dependencies_table"

describe DeltaTest::DependenciesTable do

  include FakeFS::SpecHelpers

  it "should be a subclass of Hash" do
    expect(DeltaTest::DependenciesTable).to be < Hash
  end


  let(:table) { DeltaTest::DependenciesTable.new }

  describe "#[]" do

    it "should initiate an empty set if not accessed before" do
      value = table[:foo]
      expect(value).to be_a(Set)
      expect(value).to be_empty
    end

    it "should retain elements in a set throughout accesses" do
      table[:foo] << 1
      table[:foo] << 2
      table[:foo] << 2
      table[:foo] << 3
      table[:foo] << 3
      table[:foo] << 3
      expect(table[:foo]).to eq(Set.new([1, 2, 3]))
    end

  end

  describe "#without_default_proc" do

    it "should reset default_proc temporary inside a block" do
      expect(table.default_proc).not_to be_nil
      table.without_default_proc do
        expect(table.default_proc).to be_nil
      end
      expect(table.default_proc).not_to be_nil
    end

  end

  describe "#cleanup!" do

    it "should delete items where value is an empty set" do
      table[:foo]
      table[:bar] << 1
      expect(table.keys).to eq([:foo, :bar])
      table.cleanup!
      expect(table.keys).to eq([:bar])
    end

  end

  shared_examples "init file system" do

    let!(:table) do
      table = DeltaTest::DependenciesTable.new

      table[:foo] << 1
      table[:foo] << 2
      table[:bar] << 10
      table[:bar] << 20

      table
    end

    let(:output_path) { "test" }
    let!(:file) do
      file = FakeFS::FakeFile.new
      FakeFS::FileSystem.add(output_path, file)
    end

  end

  describe "#dump" do

    include_examples "init file system"

    it "should dump a table object to a file" do
      expect(file.content).to be_empty

      expect {
        table.dump(output_path)
      }.not_to raise_error

      expect(file.content).not_to be_empty
    end

  end

  describe "::load" do

    include_examples "init file system"

    it "should restore a table object from a file" do
      table.dump(output_path)
      restored_table = nil
      expect {
        restored_table = DeltaTest::DependenciesTable.load(output_path)
      }.not_to raise_error
      expect(restored_table).to be_a(DeltaTest::DependenciesTable)
      expect(restored_table).to eq(table)
    end

  end

end
