# frozen_string_literal: true

RSpec.describe Mutant::License::Subscription do
  describe '#description' do
    def apply
      object.description
    end

    context 'on commercial license' do
      let(:object) do
        described_class::Commercial.new(
          [
            described_class::Commercial::Author.new('mbj@schirp-dso.com'),
            described_class::Commercial::Author.new('other@schirp-dso.com')
          ].to_set
        )
      end

      it 'returns expected description' do
        expect(apply).to eql(<<~'MESSAGE')
          commercial subscription:
          Licensed:
          mbj@schirp-dso.com
          other@schirp-dso.com
        MESSAGE
      end
    end

    context 'on opensource license' do
      let(:object) do
        described_class::Opensource.new(
          [
            described_class::Opensource::Repository.new('github.com', 'mbj/mutant'),
            described_class::Opensource::Repository.new('github.com', 'mbj/unparser')
          ].to_set
        )
      end

      it 'returns expected description' do
        expect(apply).to eql(<<~'MESSAGE')
          opensource subscription:
          Licensed:
          github.com/mbj/mutant
          github.com/mbj/unparser
        MESSAGE
      end
    end
  end

  describe '.load' do
    def apply
      described_class.load(world, license_json)
    end

    let(:world) { instance_double(Mutant::World) }

    before do
      allow(world).to receive(:capture_stdout, &commands.method(:fetch))
    end

    def self.it_fails(expected)
      it 'failse with exception' do
        expect { apply }.to raise_error(expected)
      end
    end

    def self.it_is_successful
      it 'allows usage' do
        expect(apply).to eql(MPrelude::Either::Right.new(subscription))
      end
    end

    def self.it_fails_with_message(expected)
      it 'returns expected message' do
        expect(apply).to eql(MPrelude::Either::Left.new(expected))
      end
    end

    describe 'on opensource license' do
      let(:git_remote_result) { Mutant::Either::Right.new(git_remote) }
      let(:repository)        { 'github.com/mbj/mutant'               }

      let(:git_remote) do
        <<~REMOTE
          origin\tgit@github.com:mbj/mutant (fetch)
          origin\tgit@github.com:mbj/mutant (push)
        REMOTE
      end

      let(:license_json) do
        {
          'type'     => 'oss',
          'contents' => {
            'repositories' => [repository]
          }
        }
      end

      let(:commands) do
        {
          %w[git remote --verbose] => git_remote_result
        }
      end

      let(:subscription) do
        Mutant::License::Subscription::Opensource.new(
          [
            Mutant::License::Subscription::Opensource::Repository.new(
              'github.com',
              'mbj/mutant'
            )
          ].to_set
        )
      end

      context 'when repository is whitelisted' do
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

        context 'on https url with .git suffix' do
          let(:git_remote) do
            <<~REMOTE
              origin\thttps://github.com/mbj/mutant.git (fetch)
              origin\thttps://github.com/mbj/mutant.git (push)
            REMOTE
          end

          it_is_successful
        end
      end

      context 'when git remote line cannot be parsed' do
        let(:git_remote) { "some-bad-remote-line\n" }

        it_fails 'Unmatched remote line: "some-bad-remote-line\n"'
      end

      context 'when git remote url cannot be parsed' do
        let(:git_remote) { "some-unknown\thttp://github.com/mbj/mutant (fetch)\n" }

        it_fails 'Unmatched git remote URL: "http://github.com/mbj/mutant"'
      end

      context 'when repository is not whitelisted' do
        let(:repository) { 'github.com/mbj/unparser' }

        it_fails_with_message(<<~'MESSAGE')
          Can not validate opensource license.
          Licensed:
          github.com/mbj/unparser
          Present:
          github.com/mbj/mutant
        MESSAGE
      end
    end

    describe 'on commercial license' do
      let(:git_config_author) { "customer-a@example.com\n"                   }
      let(:git_config_result) { Mutant::Either::Right.new(git_config_author) }
      let(:git_show_author)   { "customer-b@example.com\n"                   }
      let(:git_show_result)   { Mutant::Either::Right.new(git_show_author)   }

      let(:licensed_authors) do
        %w[
          customer-a@example.com
          customer-b@example.com
        ]
      end

      let(:license_json) do
        {
          'type'     => 'com',
          'contents' => {
            'authors' => licensed_authors
          }
        }
      end

      let(:commands) do
        {
          %w[git config --get user.email]          => git_config_result,
          %w[git show --quiet --pretty=format:%ae] => git_show_result
        }
      end

      let(:subscription) do
        Mutant::License::Subscription::Commercial.new(
          licensed_authors
            .map(&Mutant::License::Subscription::Commercial::Author.method(:new))
            .to_set
        )
      end

      context 'when author is whitelisted' do
        it_is_successful
      end

      context 'when author is not whitelisted' do
        let(:licensed_authors) { %w[customer-c@example.com] }

        it_fails_with_message(<<~'MESSAGE')
          Can not validate commercial license.
          Licensed:
          customer-c@example.com
          Present:
          customer-a@example.com
          customer-b@example.com
        MESSAGE
      end

      context 'when author cannot be found in commit or config' do
        let(:git_config_result) { Mutant::Either::Left.new('fatal: error') }
        let(:git_show_result)   { Mutant::Either::Left.new('fatal: error') }

        it_fails_with_message(<<~'MESSAGE')
          Can not validate commercial license.
          Licensed:
          customer-a@example.com
          customer-b@example.com
          Present:
          [none]
        MESSAGE
      end
    end
  end
end
