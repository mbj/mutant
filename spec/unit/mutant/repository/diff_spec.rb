describe Mutant::Repository::Diff do
  describe '.from_head' do
    subject { described_class.from_head(to_revision) }

    let(:to_revision) { double('to revision') }

    it { should eql(described_class.new('HEAD', to_revision)) }
  end

  describe '#touches?' do
    let(:object)        { described_class.new('from_rev', 'to_rev') }
    let(:path)          { Pathname.new('foo.rb')                    }
    let(:line_range)    { 1..2                                      }
    let(:status)        { double('Status', success?: success?)      }
    let(:stdout)        { double('Stdout', empty?: stdout_empty?)   }
    let(:stdout_empty?) { false                                     }

    subject { object.touches?(path, line_range) }

    before do
      expect(Open3).to receive(:capture2)
        .ordered
        .with(*expected_git_log_command, binmode: true)
        .and_return([stdout, status])
    end

    let(:expected_git_log_command) do
      %w[
        git log from_rev...to_rev -L 1,2:foo.rb
      ]
    end

    context 'on failure of git log command' do
      let(:success?) { false }

      it 'raises error' do
        expect { subject }.to raise_error(
          Mutant::Repository::RepositoryError,
          "Command #{expected_git_log_command} failed!"
        )
      end
    end

    context 'on suuccess of git command' do
      let(:success?) { true }

      context 'on empty stdout' do
        let(:stdout_empty?) { true }

        it { should be(false) }
      end

      context 'on non empty stdout' do
        let(:stdout_empty?) { false }

        it { should be(true) }
      end
    end
  end
end
