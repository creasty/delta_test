require 'delta_test/cli/version_command'

describe DeltaTest::CLI::VersionCommand do

  let(:command) { DeltaTest::CLI::VersionCommand.new([]) }

  describe '#invoke!' do

    it 'should print help' do
      expect {
        command.invoke!
      }.to output(/v\d+\.\d+.\d+/).to_stdout
    end

  end

end
