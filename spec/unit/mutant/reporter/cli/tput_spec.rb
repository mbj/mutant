RSpec.describe Mutant::Reporter::CLI::Tput do
  describe '.detect' do
    subject { described_class.detect }

    def expect_command(command, stdout, success)
      allow(Open3).to receive(:capture3).with(command).and_return(
        [
          stdout,
          instance_double(IO),
          instance_double(Process::Status, success?: success)
        ]
      )
    end

    let(:tput_reset?) { true }
    let(:tput_sc?)    { true }
    let(:tput_rc?)    { true }
    let(:tput_ed?)    { true }

    before do
      expect_command('tput reset', '[reset]', tput_reset?)
      expect_command('tput sc', '[sc]', tput_sc?)
      expect_command('tput rc', '[rc]', tput_rc?)
      expect_command('tput ed', '[ed]', tput_ed?)
    end

    context 'when all tput commands are supported' do
      its(:prepare) { should eql('[reset][sc]') }
      its(:restore) { should eql('[rc][ed]')    }
    end

    context 'when tput reset fails' do
      let(:tput_reset?) { false }

      it { should be(nil) }
    end

    context 'when ed fails' do
      let(:tput_ed?) { false }
      let(:tput_cd?) { true }
      before do
        expect_command('tput cd', '[cd]', tput_cd?)
      end
      its(:prepare) { should eql('[reset][sc]') }
      its(:restore) { should eql('[rc][cd]')    }
    end
  end
end
