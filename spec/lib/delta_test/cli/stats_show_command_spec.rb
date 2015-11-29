require 'delta_test/cli/stats_show_command'
require 'delta_test/related_spec_list'
require 'delta_test/stats'

describe DeltaTest::CLI::StatsShowCommand do

  let(:command) { DeltaTest::CLI::StatsShowCommand.new([]) }

  let(:table) do
    {
      'spec/foo_spec.rb' => ['lib/foo.rb']
    }
  end

  let(:base_commit) { '1111111111111111111111111111111111111111' }

  before do
    allow($stdout).to receive(:puts).and_return(nil)
    allow($stderr).to receive(:puts).and_return(nil)

    allow_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!).and_return(nil)
    allow_any_instance_of(DeltaTest::RelatedSpecList).to receive(:table).and_return(table)

    allow_any_instance_of(DeltaTest::Stats).to receive(:base_commit).and_return(base_commit)
  end

  describe '#invoke!' do

    it 'should raise an error if a base commit does not exist' do
      allow_any_instance_of(DeltaTest::Stats).to receive(:base_commit).and_return(nil)

      expect {
        command.invoke!
      }.to raise_error(DeltaTest::StatsNotFoundError)
    end

    it 'should load a table file' do
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!)
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:table)

      expect {
        command.invoke!
      }.not_to raise_error
    end

    it 'should show the table contents' do
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!)
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:table)

      expect {
        command.invoke!
      }.to output(/foo_spec\.rb/).to_stdout
    end

  end

end
