require 'delta_test/cli'
require 'delta_test/cli/exec_command'
require 'delta_test/cli/specs_command'
require 'delta_test/cli/stats_show_command'
require 'delta_test/cli/stats_save_command'
require 'delta_test/cli/version_command'
require 'delta_test/cli/help_command'

describe DeltaTest::CLI do

  describe '#run' do

    describe 'exec' do

      it 'should call invoke on ExecCommand' do
        expect(DeltaTest::CLI::ExecCommand).to receive(:new).with(['echo']).and_call_original
        expect_any_instance_of(DeltaTest::CLI::ExecCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['exec', 'echo']).run
      end

    end

    describe 'specs' do

      it 'should call invoke on SpecsCommand' do
        expect(DeltaTest::CLI::SpecsCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::SpecsCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['specs']).run
      end

    end

    describe 'stats:show' do

      it 'should call invoke on StatsShowCommand' do
        expect(DeltaTest::CLI::StatsShowCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::StatsShowCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['stats:show']).run
      end

    end

    describe 'stats:save' do

      it 'should call invoke on StatsSaveCommand' do
        expect(DeltaTest::CLI::StatsSaveCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::StatsSaveCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['stats:save']).run
      end

    end

    describe 'version' do

      it 'should call invoke on VersionCommand' do
        expect(DeltaTest::CLI::VersionCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::VersionCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['version']).run
      end

    end

    describe 'help' do

      it 'should call invoke on HelpCommand' do
        expect(DeltaTest::CLI::HelpCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::HelpCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['help']).run
      end

    end

    describe '(other)' do

      it 'should call invoke on HelpCommand' do
        expect(DeltaTest::CLI::HelpCommand).to receive(:new).with([]).and_call_original
        expect_any_instance_of(DeltaTest::CLI::HelpCommand).to receive(:invoke).and_return(nil)

        DeltaTest::CLI.new(['foo']).run
      end

    end

  end

end
