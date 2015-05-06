shared_examples :defer_create_table_file do

  let(:table_file_path) { "/base_path/table_file" }

  let(:table_file) do
    file = FakeFS::FakeFile.new
    FakeFS::FileSystem.add(table_file_path, file)
    file
  end

end

shared_examples :create_table_file do

  include_examples :defer_create_table_file

  before do
    table_file
  end

end
