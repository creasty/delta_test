require 'delta_test/cli/specs_command'

describe DeltaTest::CLI::SpecsCommand do

  let(:command) { DeltaTest::CLI::SpecsCommand.new([]) }

  let(:related_spec_files) do
    [
      'spec/foo_spec.rb',
    ]
  end

  let(:base_commit) { '1111111111111111111111111111111111111111' }

  before do
    allow(command.list).to receive(:load_table!).and_return(nil)
    allow(command.list).to receive(:retrive_changed_files!).and_return(nil)
    allow(command.list).to receive(:related_spec_files).and_return(related_spec_files)

    allow(command.stats).to receive(:base_commit).and_return(base_commit)
    allow(command.stats).to receive(:table_file_path).and_return(nil)
  end

  describe '#invoke!' do

    it 'should raise an error if a base commit does not exist' do
      allow(command.stats).to receive(:base_commit).and_return(nil)

      expect {
        command.invoke!
      }.to raise_error(DeltaTest::StatsNotFoundError)
    end

    it 'should load a table file and retrive changed files' do
      expect(command.list).to receive(:load_table!).once
      expect(command.list).to receive(:retrive_changed_files!).once

      expect {
        command.invoke!
      }.not_to raise_error
    end

    it 'should show a list of related spec files' do
      expect(command.list).to receive(:load_table!).once
      expect(command.list).to receive(:retrive_changed_files!).once
      expect(command.list).to receive(:related_spec_files).once

      expect {
        command.invoke!
      }.to output(/foo_spec\.rb/).to_stdout
    end

  end

end
