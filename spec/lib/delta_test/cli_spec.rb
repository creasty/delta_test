require 'delta_test/cli'

describe DeltaTest::CLI do

  let(:cli) { DeltaTest::CLI.new }

  describe '#run' do

    before do
      allow(cli).to receive(:invoke).with(no_args).and_return(nil)
    end

    it 'should set the first argument as command' do
      args = ['command', 'foo', 'bar']
      cli.run(args)
      expect(cli.command).to eq(args[0])
    end

    it 'should call `parse_options!` and `invoke`' do
      expect(cli).to receive(:parse_options!).with(no_args).once.ordered
      expect(cli).to receive(:invoke).with(no_args).once.ordered

      args = ['command', 'foo', 'bar']
      cli.run(args)
    end

  end

  describe '#parse_options!' do

    before do
      DeltaTest::CLI.class_eval do
        attr_accessor :args
      end
    end

    it 'should parse short options' do
      cli.args = ['-a', '-b']

      options = cli.parse_options!

      expect(cli.args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['b']).to be(true)
    end

    it 'should parse long options' do
      cli.args = ['--long-a', '--long-b']

      options = cli.parse_options!

      expect(cli.args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be(true)
    end

    it 'should parse long options with value' do
      cli.args = ['--long-a=value-of-a', '--long-b=value-of-b']

      options = cli.parse_options!

      expect(cli.args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to eq('value-of-a')
      expect(options['long-b']).to eq('value-of-b')
    end

    it 'should not parse options after once non-option args appears' do
      cli.args = ['-a', '--long-a', 'non-option', '--long-b=value-of-b']

      options = cli.parse_options!

      expect(cli.args).to eq(['non-option', '--long-b=value-of-b'])
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be_nil
    end

    describe 'Defaults' do

      it 'should set default options' do
        cli.args = []

        options = cli.parse_options!

        expect(options).to be_a(Hash)

        expect(options['base']).to eq('master')
        expect(options['head']).to eq('HEAD')
      end

      it 'should be able to overwrite default options' do
        cli.args = ['--base=develop', '--head=feature/foo']

        options = cli.parse_options!

        expect(options).to be_a(Hash)

        expect(options['base']).to eq('develop')
        expect(options['head']).to eq('feature/foo')
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
            cli.exit_with_message(status, message)
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
            cli.exit_with_message(status, message)
          rescue SystemExit => e
            expect(e.status).to eq(status)
          end
        }.to output(message_regexp).to_stderr
      end

    end

  end

end
