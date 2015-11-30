require 'delta_test/cli/exec_command'

describe DeltaTest::CLI::ExecCommand do

  let(:args) { ['bundle', 'exec', 'rspec'] }
  let(:command) { DeltaTest::CLI::ExecCommand.new(args) }

  let(:table) do
    {
      'spec/foo_spec.rb' => ['lib/foo.rb']
    }
  end

  let(:related_spec_files) do
    [
      'spec/foo_spec.rb',
    ]
  end

  let(:base_commit) { '1111111111111111111111111111111111111111' }

  before do
    allow(command.list).to receive(:load_table!).and_return(nil)
    allow(command.list).to receive(:table).and_return(table)
    allow(command.list).to receive(:retrive_changed_files!).and_return(nil)
    allow(command.list).to receive(:related_spec_files).and_return(related_spec_files)

    allow(command.stats).to receive(:base_commit).and_return(base_commit)
    allow(command.stats).to receive(:table_file_path).and_return(nil)
  end

  describe '#profile_mode?' do

    it 'should return false if a base commit exists' do
      expect(command.profile_mode?).to be(false)
    end

    it 'should return true if a base commit does not exist' do
      allow(command.stats).to receive(:base_commit).and_return(nil)
      expect(command.profile_mode?).to be(true)
    end

    it 'should be able to override by an instance variable' do
      expect(command.profile_mode?).to be(false)
      command.instance_variable_set(:@profile_mode, true)
      expect(command.profile_mode?).to be(true)
    end

    context 'with --force' do

      let(:args) { ['--force', 'bundle', 'exec', 'rspec'] }

      it 'should always return true' do
        allow(command.stats).to receive(:base_commit).and_return(nil)
        expect(command.profile_mode?).to be(true)
      end

    end

  end

  describe '#invoke!' do

    before do
      allow(command).to receive(:exec_with_data).and_return(nil)
    end

    context 'Full tests' do

      before do
        allow(command).to receive(:profile_mode?).and_return(true)
      end

      it 'should run script with a flag' do
        expect(command.list).not_to receive(:related_spec_files)

        _args = ['%s=%s' % [DeltaTest::ACTIVE_FLAG, true], *args].join(' ')
        expect(command).to receive(:exec_with_data).with(_args, nil)

        expect {
          command.invoke!
        }.not_to raise_error
      end

    end

    context 'Partial tests' do

      before do
        allow(command).to receive(:profile_mode?).and_return(false)
      end

      context 'Any related files' do

        it 'should run script with related spec files' do
          expect(command.list).to receive(:related_spec_files)

          _args = ['cat', '|', 'xargs', *args].join(' ')
          expect(command).to receive(:exec_with_data).with(_args, related_spec_files)

          expect {
            command.invoke!
          }.not_to raise_error
        end

      end

      context 'No related files' do

        let(:related_spec_files) { [] }

        it 'should not run script and exit with a message' do
          expect(command.list).to receive(:related_spec_files)

          expect {
            begin
              command.invoke!
            rescue SystemExit => e
              expect(e.status).to eq(0)
            end
          }.to output(/Nothing/).to_stdout
        end

      end

    end

  end
end
