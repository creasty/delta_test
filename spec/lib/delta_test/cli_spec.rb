require 'delta_test/cli'
require 'delta_test/git'

describe DeltaTest::CLI do

  let(:cli) { DeltaTest::CLI.new }

  before do
    DeltaTest::CLI.class_eval do
      attr_writer :args
      attr_writer :options
      attr_writer :command
      attr_reader :list
    end

    # ignore outputs
    allow($stdout).to receive(:puts).with(any_args).and_return(nil)
    allow($stderr).to receive(:puts).with(any_args).and_return(nil)
  end

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

  describe '#run_full_tests?' do

    let(:map) do
      {
        'master'      => '0000000000000000000000000000000000000000',
        'feature/foo' => '1111111111111111111111111111111111111111',
      }
    end

    before do
      map.each do |name, commit_id|
        allow(DeltaTest::Git).to receive(:rev_parse).with(name).and_return(commit_id)
      end
    end

    context 'When base and head is the same commit' do

      before do
        cli.options = {
          'base' => 'master',
          'head' => 'master',
        }
      end

      it 'should return true' do
        expect(cli.run_full_tests?).to be(true)
      end

    end

    context 'When base and head is a different commit' do

      before do
        cli.options = {
          'base' => 'master',
          'head' => 'feature/foo',
        }
      end

      it 'should return false' do
        expect(cli.run_full_tests?).to be(false)
      end

    end

  end

  context 'Commands' do

    describe '#do_table' do

      let(:table) do
        {
          'spec/foo_spec.rb' => ['lib/foo.rb']
        }
      end

      before do
        allow(cli).to receive(:invoke).with(no_args).and_return(nil)

        cli.run([])

        allow(cli.list).to receive(:load_table!).with(no_args).and_return(nil)
        allow(cli.list).to receive(:table).with(no_args).and_return(table)
      end

      it 'should load a table file' do
        expect(cli.list).to receive(:load_table!).with(no_args).once.ordered
        expect(cli.list).to receive(:table).with(no_args).once.ordered

        expect {
          cli.do_table
        }.not_to raise_error
      end

      it 'should show the table contents' do
        expect(cli.list).to receive(:load_table!).with(no_args).once.ordered
        expect(cli.list).to receive(:table).with(no_args).once.ordered

        expect {
          cli.do_table
        }.to output(/foo_spec\.rb/).to_stdout
      end

    end

    describe '#do_list' do

      let(:related_spec_files) do
        [
          'spec/foo_spec.rb',
        ]
      end

      before do
        allow(cli).to receive(:invoke).with(no_args).and_return(nil)

        cli.run([])

        allow(cli.list).to receive(:load_table!).with(no_args).and_return(nil)
        allow(cli.list).to receive(:retrive_changed_files!).with(any_args).and_return(nil)
        allow(cli.list).to receive(:related_spec_files).with(no_args).and_return(related_spec_files)
      end

      it 'should load a table file and retrive changed files' do
        expect(cli.list).to receive(:load_table!).with(no_args).once.ordered
        expect(cli.list).to receive(:retrive_changed_files!).with(any_args).once.ordered

        expect {
          cli.do_list
        }.not_to raise_error
      end

      it 'should show a list of related spec files' do
        expect(cli.list).to receive(:load_table!).with(no_args).once.ordered
        expect(cli.list).to receive(:retrive_changed_files!).with(any_args).once.ordered
        expect(cli.list).to receive(:related_spec_files).with(no_args).once.ordered

        expect {
          cli.do_list
        }.to output(/foo_spec\.rb/).to_stdout
      end

    end

    describe '#do_exec' do

      let(:args) do
        ['exec', 'bundle', 'exec', 'rspec']
      end

      let(:related_spec_files) do
        [
          'spec/foo_spec.rb',
        ]
      end

      before do
        allow(cli).to receive(:invoke).with(no_args).and_return(nil)

        cli.run(args)

        allow(cli.list).to receive(:load_table!).with(no_args).and_return(nil)
        allow(cli.list).to receive(:retrive_changed_files!).with(any_args).and_return(nil)
        allow(cli.list).to receive(:related_spec_files).with(no_args).and_return(related_spec_files)

        allow(Open3).to receive(:popen3).with(any_args).and_return(nil)
      end

      context 'Full tests' do

        before do
          expect(cli).to receive(:run_full_tests?).with(no_args).and_return(true)
        end

        it 'should run script with a flag' do
          expect(cli.list).not_to receive(:related_spec_files).with(no_args)

          _args = ['%s=%s' % [DeltaTest::ACTIVE_FLAG, true], *args[1..-1]].join(' ')
          expect(Open3).to receive(:popen3).with(_args)

          expect {
            cli.do_exec
          }.not_to raise_error
        end

      end

      context 'Partial tests' do

        before do
          expect(cli).to receive(:run_full_tests?).with(no_args).and_return(false)
        end

        context 'Any related files' do

          it 'should run script with related spec files' do
            expect(cli.list).to receive(:related_spec_files).with(no_args)

            _args = ['cat', '|', 'xargs', *args[1..-1]].join(' ')
            expect(Open3).to receive(:popen3).with(_args)

            expect {
              cli.do_exec
            }.not_to raise_error
          end

        end

        context 'No related files' do

          let(:related_spec_files) { [] }

          it 'should not run script and exit with a message' do
            expect(cli.list).to receive(:related_spec_files).with(no_args)

            expect {
              begin
                cli.do_exec
              rescue SystemExit => e
                expect(e.status).to eq(0)
              end
            }.to output(/Nothing/).to_stdout
          end

        end

      end

    end

    describe '#do_help' do

      it 'should print help' do
        expect {
          cli.do_help
        }.to output(/usage/).to_stdout
      end

    end

  end

  describe '#invoke' do

    let(:commands) do
      %w[
        list
        table
        exec
        help
      ]
    end

    before do
      commands.each do |command|
        allow(cli).to receive('do_%s' % command).with(no_args).and_return(nil)
      end
    end

    it 'should invoke method for a command' do
      commands.each do |command|
        expect(cli).to receive('do_%s' % command).with(no_args)

        cli.command = command

        expect {
          cli.invoke
        }.not_to raise_error
      end
    end

  end

end
