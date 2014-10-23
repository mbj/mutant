RSpec.describe Mutant::Result::Env do
  let(:object) do
    described_class.new(
      env:              double('Env', config: config),
      runtime:          double('Runtime'),
      subject_results:  subject_results
    )
  end

  let(:config) { double('Config', fail_fast: fail_fast) }

  describe '#continue?' do
    subject { object.continue? }

    context 'config sets fail_fast flag' do
      let(:fail_fast) { true }

      context 'when mutation results are empty' do
        let(:subject_results) { [] }

        it { should be(true) }
      end

      context 'with failing mutation result' do
        let(:subject_results) { [double('Subject Result', success?: false)] }

        it { should be(false) }
      end

      context 'with successful mutation result' do
        let(:subject_results) { [double('Subject Result', success?: true)] }

        it { should be(true) }
      end

      context 'with failed and successful mutation result' do
        let(:subject_results) do
          [
            double('Subject Result', success?: true),
            double('Subject Result', success?: false)
          ]
        end

        it { should be(false) }
      end
    end

    context 'config does not set fail fast flag' do
      let(:fail_fast)       { false                     }
      let(:subject_results) { double('subject results') }

      it { should be(true) }
    end
  end
end
