require 'delta_test/cli/stats_show_command'

describe DeltaTest::CLI::StatsShowCommand do

  let(:command) { DeltaTest::CLI::StatsShowCommand.new([]) }

  let(:table) do
    {
      'spec/foo_spec.rb' => ['lib/foo.rb']
    }
  end

  let(:base_commit) { '1111111111111111111111111111111111111111' }

  before do
    allow(command.list).to receive(:load_table!).and_return(nil)
    allow(command.list).to receive(:table).and_return(table)

    allow(command.stats).to receive(:base_commit).and_return(base_commit)
  end

  describe '#invoke!' do

    it 'should raise an error if a base commit does not exist' do
      allow(command.stats).to receive(:base_commit).and_return(nil)

      expect {
        command.invoke!
      }.to raise_error(DeltaTest::StatsNotFoundError)
    end

    it 'should load a table file' do
      expect(command.list).to receive(:load_table!)
      expect(command.list).to receive(:table)

      expect {
        command.invoke!
      }.not_to raise_error
    end

    it 'should show the table contents' do
      expect(command.list).to receive(:load_table!)
      expect(command.list).to receive(:table)

      expect {
        command.invoke!
      }.to output(/foo_spec\.rb/).to_stdout
    end

  end

end
