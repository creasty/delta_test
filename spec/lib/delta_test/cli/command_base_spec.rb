require 'delta_test/cli/command_base'

describe DeltaTest::CLI::CommandBase do

  let(:command_base) { DeltaTest::CLI::CommandBase.new([]) }

  describe '#invoke!' do

    it 'should raise a not implemented error' do
      expect {
        command_base.invoke!
      }.to raise_error
    end

  end

  describe '#invoke' do

    context 'verbose=false' do

      it 'should call `invoke!`' do
        allow(DeltaTest).to receive(:verbose?).and_return(false)
        expect(command_base).to receive(:invoke!).and_return(nil)
        command_base.invoke
      end

      it 'should exit with an error message' do
        expect(command_base).to receive(:exit_with_message)
        command_base.invoke
      end

    end

    context 'verbose=true' do

      it 'should call `invoke!`' do
        allow(DeltaTest).to receive(:verbose?).and_return(false)
        expect(command_base).to receive(:invoke!).and_return(nil)
        command_base.invoke!
      end

      it 'should raise an error' do
        expect {
          command_base.invoke
        }.to raise_error
      end

    end

  end

  describe '#parse_options!' do

    it 'should parse short options' do
      args = ['-a', '-b']
      options = command_base.parse_options!(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['b']).to be(true)
    end

    it 'should parse long options' do
      args = ['--long-a', '--long-b']
      options = command_base.parse_options!(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be(true)
    end

    it 'should parse long options with value' do
      args = ['--long-a=value-of-a', '--long-b=value-of-b']
      options = command_base.parse_options!(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to eq('value-of-a')
      expect(options['long-b']).to eq('value-of-b')
    end

    it 'should not parse options after once non-option args appears' do
      args = ['-a', '--long-a', 'non-option', '--long-b=value-of-b']
      options = command_base.parse_options!(args)

      expect(args).to eq(['non-option', '--long-b=value-of-b'])
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be_nil
    end

    describe 'Defaults' do

      it 'should set default options' do
        args = []
        options = command_base.parse_options!(args)

        expect(options).to be_a(Hash)

        expect(options['force-run']).to eq(false)
        expect(options['verbose']).to eq(false)
      end

      it 'should be able to overwrite default options' do
        args = ['--force-run', '--verbose']
        options = command_base.parse_options!(args)

        expect(options).to be_a(Hash)

        expect(options['force-run']).to eq(true)
        expect(options['verbose']).to eq(true)
      end

    end

  end

  describe '#exit_with_message' do

    let(:message)        { 'a message' }
    let(:message_regexp) { /a message/ }

    context 'With status code of zero' do

      let(:status)  { 0 }

      it 'should print a message to stdout and exit' do
        expect {
          begin
            command_base.exit_with_message(status, message)
          rescue SystemExit => e
            expect(e.status).to eq(status)
          end
        }.to output(message_regexp).to_stdout
      end

    end

    context 'With status code of non-zero' do

      let(:status)  { 1 }

      it 'should print a message to stderr and exit' do
        expect {
          begin
            command_base.exit_with_message(status, message)
          rescue SystemExit => e
            expect(e.status).to eq(status)
          end
        }.to output(message_regexp).to_stderr
      end

    end

  end

  describe '#bundler_enabled?' do

  end

end
