require 'delta_test/cli/help_command'

describe DeltaTest::CLI::HelpCommand do

  before do
    allow($stdout).to receive(:puts).with(any_args).and_return(nil)
  end

  let(:command) { DeltaTest::CLI::HelpCommand.new([]) }

  describe '#invoke!' do

    it 'should print gem version' do
      expect {
        command.invoke!
      }.to output(/usage/).to_stdout
    end

  end

end
