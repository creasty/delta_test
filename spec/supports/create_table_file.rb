shared_examples :defer_create_table_file do

  let(:stats_path) { '/base_path/stats_path' }
  let(:tmp_stats_file_path) { [stats_path, 'tmp', DeltaTest.tester_id].join('/') }

  let(:table_file_path) { Pathname.new('/base_path/file_path') }

  let(:tmp_stats_file) do
    file = FakeFS::FakeFile.new
    FakeFS::FileSystem.add(tmp_stats_file_path, file)
    file
  end

  let(:table_file) do
    file = FakeFS::FakeFile.new
    FakeFS::FileSystem.add(table_file_path, file)
    file
  end

end

shared_examples :create_table_file do

  include_examples :defer_create_table_file

  before do
    tmp_stats_file
    table_file
  end

end
