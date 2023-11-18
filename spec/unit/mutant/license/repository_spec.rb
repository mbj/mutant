# frozen_string_literal: true

RSpec.describe Mutant::License::Subscription::Repository do
  def self.it_fails(expected)
    it 'failse with exception' do
      expect { apply }.to raise_error(expected)
    end
  end

  def self.it_is_successful
    it 'returns expected repositories' do
      expect(apply).to eql(right(repositories))
    end
  end

  def self.it_fails_with_message(expected)
    it 'returns expected message' do
      expect(apply).to eql(left(expected))
    end
  end

  describe '.parse' do
    def apply
      described_class.parse(input)
    end

    let(:expected) do
      described_class.new(host: 'github.com', path: 'mbj/mutant')
    end

    context 'one to one' do
      let(:input) { 'github.com/mbj/mutant' }

      it 'returns expected value' do
        expect(apply).to eql(expected)
      end
    end

    context 'downcase' do
      let(:input) { 'github.com/Mbj/Mutant' }

      it 'returns expected value' do
        expect(apply).to eql(expected)
      end
    end
  end

  describe '#to_s' do
    def apply
      described_class.new(host: 'github.com', path: 'mbj/mutant').to_s
    end

    it 'returns expected value' do
      expect(apply).to eql('github.com/mbj/mutant')
    end
  end

  describe '.load_from_git' do
    def apply
      described_class.load_from_git(world)
    end

    let(:world) { instance_double(Mutant::World) }

    before do
      allow(world).to receive(:capture_stdout, &commands.public_method(:fetch))
    end

    let(:git_remote_result)    { right(git_remote)         }
    let(:allowed_repositories) { %w[github.com/mbj/mutant] }

    let(:git_remote) do
      <<~REMOTE
        origin\tgit@github.com:mbj/Mutant (fetch)
        origin\tgit@github.com:mbj/Mutant (push)
      REMOTE
    end

    let(:commands) do
      {
        %w[git remote --verbose] => git_remote_result
      }
    end

    let(:repositories) do
      [
        described_class.new(
          host: 'github.com',
          path: 'mbj/mutant'
        )
      ].to_set
    end

    context 'on different casing' do
      let(:allowed_repositories) { %w[github.com/MBJ/MUTANT] }

      it_is_successful
    end

    context 'on ssh url without protocol and without suffix' do
      it_is_successful
    end

    context 'on ssh url with protocol and without suffix' do
      let(:git_remote) do
        <<~REMOTE
          origin\tssh://git@github.com/mbj/mutant (fetch)
          origin\tssh://git@github.com/mbj/mutant (push)
        REMOTE
      end

      it_is_successful
    end

    context 'on ssh url with protocol and suffix' do
      let(:git_remote) do
        <<~REMOTE
          origin\tssh://git@github.com/mbj/mutant.git (fetch)
          origin\tssh://git@github.com/mbj/mutant.git (push)
        REMOTE
      end

      it_is_successful
    end

    context 'on https url without suffix' do
      let(:git_remote) do
        <<~REMOTE
          origin\thttps://github.com/mbj/mutant (fetch)
          origin\thttps://github.com/mbj/mutant (push)
        REMOTE
      end

      it_is_successful
    end

    context 'on multiple different urls' do
      let(:git_remote) do
        <<~REMOTE
          origin\thttps://github.com/mbj/mutant (fetch)
          origin\thttps://github.com/mbj/mutant (push)
          origin\thttps://github.com/mbj/unparser (fetch)
          origin\thttps://github.com/mbj/unparser (push)
        REMOTE
      end

      let(:repositories) do
        [
          described_class.new(
            host: 'github.com',
            path: 'mbj/mutant'
          ),
          described_class.new(
            host: 'github.com',
            path: 'mbj/unparser'
          )
        ].to_set
      end

      it_is_successful
    end

    context 'on https url with .git suffix' do
      let(:git_remote) do
        <<~REMOTE
          origin\thttps://github.com/mbj/mutant.git (fetch)
          origin\thttps://github.com/mbj/mutant.git (push)
        REMOTE
      end

      it_is_successful
    end

    context 'when git remote line cannot be parsed' do
      let(:git_remote) { "some-bad-remote-line\n" }

      it_fails 'Unmatched remote line: "some-bad-remote-line\n"'
    end

    context 'when git remote url cannot be parsed' do
      let(:git_remote) { "some-unknown\thttp://github.com/mbj/mutant (fetch)\n" }

      it_fails 'Unmatched git remote URL: "http://github.com/mbj/mutant"'
    end
  end

  describe 'allow?' do
    subject { described_class.new(host: 'github.com', path: 'mbj/mutant') }

    def self.it_returns_false
      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    def self.it_returns_true
      it 'returns false' do
        expect(apply).to be(true)
      end
    end

    def apply
      subject.allow?(other)
    end

    context 'when repository is allowed' do
      context 'via full match' do
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/mutant') }

        it_returns_true
      end

      context 'via path pattern on right hand site' do
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/*') }

        it_returns_true
      end

      context 'via path pattern on left hand site' do
        subject { described_class.new(host: 'github.com', path: 'mbj/*')          }
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/mutant') }

        it_returns_true
      end

      context 'via path pattern on both sides' do
        subject { described_class.new(host: 'github.com', path: 'mbj/*')     }
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/*') }

        it_returns_true
      end
    end

    context 'when repository is not allowed' do
      context 'on different host' do
        let(:other) { described_class.new(host: 'gitlab.com', path: 'mbj/mutant') }

        it_returns_false
      end

      context 'on different depository last empty' do
        subject { described_class.new(host: 'github.com', path: 'b') }

        let(:other) { described_class.new(host: 'github.com', path: 'a') }

        it_returns_false
      end

      context 'on different depository last chars' do
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/mutantb') }

        it_returns_false
      end

      context 'on different depository partial overlap' do
        let(:other) { described_class.new(host: 'github.com', path: 'mb/*') }

        it_returns_false
      end

      context 'on different org path pattern' do
        let(:other) { described_class.new(host: 'github.com', path: 'schirp-dso/*') }

        it_returns_false
      end

      context 'on different org' do
        let(:other) { described_class.new(host: 'github.com', path: 'schirp-dso/mutant') }

        it_returns_false
      end

      context 'on different repo' do
        let(:other) { described_class.new(host: 'github.com', path: 'mbj/unparser') }

        it_returns_false
      end
    end
  end
end
