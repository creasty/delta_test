require 'delta_test/cli/specs_command'
require 'delta_test/related_spec_list'
require 'delta_test/stats'

describe DeltaTest::CLI::SpecsCommand do

  let(:command) { DeltaTest::CLI::SpecsCommand.new([]) }

  let(:related_spec_files) do
    [
      'spec/foo_spec.rb',
    ]
  end

  let(:base_commit) { '1111111111111111111111111111111111111111' }

  before do
    allow($stdout).to receive(:puts).and_return(nil)
    allow($stderr).to receive(:puts).and_return(nil)

    allow_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!).and_return(nil)
    allow_any_instance_of(DeltaTest::RelatedSpecList).to receive(:retrive_changed_files!).and_return(nil)
    allow_any_instance_of(DeltaTest::RelatedSpecList).to receive(:related_spec_files).and_return(related_spec_files)

    allow_any_instance_of(DeltaTest::Stats).to receive(:base_commit).and_return(base_commit)
  end

  describe '#invoke!' do

    it 'should raise an error if a base commit does not exist' do
      allow_any_instance_of(DeltaTest::Stats).to receive(:base_commit).and_return(nil)

      expect {
        command.invoke!
      }.to raise_error(DeltaTest::StatsNotFoundError)
    end

    it 'should load a table file and retrive changed files' do
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!).once
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:retrive_changed_files!).once

      expect {
        command.invoke!
      }.not_to raise_error
    end

    it 'should show a list of related spec files' do
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:load_table!).once
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:retrive_changed_files!).once
      expect_any_instance_of(DeltaTest::RelatedSpecList).to receive(:related_spec_files).once

      expect {
        command.invoke!
      }.to output(/foo_spec\.rb/).to_stdout
    end

  end

end
