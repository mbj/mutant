# frozen_string_literal: true

RSpec.describe Mutant::License::Subscription do
  describe '#description' do
    def apply
      object.description
    end

    context 'on commercial license' do
      context 'on individual license' do
        let(:object) do
          described_class::Commercial::Individual.new(
            licensed: [
              described_class::Commercial::Individual::Author.new(email: 'mbj@schirp-dso.com'),
              described_class::Commercial::Individual::Author.new(email: 'other@schirp-dso.com')
            ].to_set
          )
        end

        it 'returns expected description' do
          expect(apply).to eql(<<~'MESSAGE')
            commercial individual subscription:
            Licensed:
            mbj@schirp-dso.com
            other@schirp-dso.com
          MESSAGE
        end
      end

      context 'on organization license' do
        let(:object) do
          described_class::Commercial::Organization.new(
            licensed: [
              described_class::Repository.new(host: 'github.com', path: 'mbj/*'),
              described_class::Repository.new(host: 'github.com', path: 'schirp-dso/*')
            ].to_set
          )
        end

        it 'returns expected description' do
          expect(apply).to eql(<<~'MESSAGE')
            commercial organization subscription:
            Licensed:
            github.com/mbj/*
            github.com/schirp-dso/*
          MESSAGE
        end
      end
    end

    context 'on opensource license' do
      let(:object) do
        described_class::Opensource.new(
          licensed: [
            described_class::Repository.new(host: 'github.com', path: 'mbj/mutant'),
            described_class::Repository.new(host: 'github.com', path: 'mbj/unparser')
          ].to_set
        )
      end

      it 'returns expected description' do
        expect(apply).to eql(<<~'MESSAGE')
          opensource repository subscription:
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
      allow(world).to receive(:capture_stdout, &commands.public_method(:fetch))
    end

    def self.it_fails(expected)
      it 'failse with exception' do
        expect { apply }.to raise_error(expected)
      end
    end

    def self.it_is_successful
      it 'allows usage' do
        expect(apply).to eql(right(subscription))
      end
    end

    def self.it_fails_with_message(expected)
      it 'returns expected message' do
        expect(apply).to eql(left(expected))
      end
    end

    describe 'on opensource license' do
      let(:git_remote_result)    { right(git_remote)         }
      let(:allowed_repositories) { %w[github.com/mbj/mutant] }

      let(:license_json) do
        {
          'type'     => 'oss',
          'contents' => {
            'repositories' => allowed_repositories
          }
        }
      end

      let(:commands) do
        {
          %w[git remote --verbose] => git_remote_result
        }
      end

      let(:git_remote) do
        <<~REMOTE
          origin\tgit@github.com:mbj/mutant (fetch)
          origin\tgit@github.com:mbj/mutant (push)
        REMOTE
      end

      context 'on one of many match' do
        let(:allowed_repositories) { %w[github.com/mbj/something github.com/mbj/mutant] }

        let(:git_remote) do
          <<~REMOTE
            origin\tgit@github.com:mbj/mutant (fetch)
            origin\tgit@github.com:mbj/mutant (push)
            origin\tgit@github.com:mbj/unparser (fetch)
            origin\tgit@github.com:mbj/unparser (push)
          REMOTE
        end

        let(:subscription) do
          Mutant::License::Subscription::Opensource.new(
            licensed: [
              Mutant::License::Subscription::Repository.new(
                host: 'github.com',
                path: 'mbj/mutant'
              ),
              Mutant::License::Subscription::Repository.new(
                host: 'github.com',
                path: 'mbj/something'
              )
            ].to_set
          )
        end
        it_is_successful
      end

      context 'on direct match' do
        let(:subscription) do
          Mutant::License::Subscription::Opensource.new(
            licensed: [
              Mutant::License::Subscription::Repository.new(
                host: 'github.com',
                path: 'mbj/mutant'
              )
            ].to_set
          )
        end
        it_is_successful
      end

      context 'when repository is not whitelisted' do
        let(:allowed_repositories) { %w[gitlab.com/mbj/mutant] }

        it_fails_with_message(<<~'MESSAGE')
          Can not validate opensource repository license.
          Licensed:
          gitlab.com/mbj/mutant
          Present:
          github.com/mbj/mutant
        MESSAGE
      end
    end

    describe 'on commercial license' do
      context 'on organization licenses' do
        let(:git_remote_result) { right(git_remote) }

        let(:license_json) do
          {
            'type'     => 'com',
            'contents' => {
              'type'         => 'organization',
              'repositories' => allowed_repositories
            }
          }
        end

        let(:commands) do
          {
            %w[git remote --verbose] => git_remote_result
          }
        end

        let(:git_remote) do
          <<~REMOTE
            origin\tgit@github.com:mbj/Mutant (fetch)
            origin\tgit@github.com:mbj/Mutant (push)
          REMOTE
        end

        let(:allowed_repositories) { %w[github.com/mbj/mutant] }

        context 'on a direct match' do
          let(:subscription) do
            Mutant::License::Subscription::Commercial::Organization.new(
              licensed: [
                Mutant::License::Subscription::Repository.new(
                  host: 'github.com',
                  path: 'mbj/mutant'
                )
              ].to_set
            )
          end

          it_is_successful
        end

        context 'on a one of many match' do
          let(:allowed_repositories) { %w[github.com/mbj/something github.com/mbj/mutant] }

          let(:git_remote) do
            <<~REMOTE
              origin\tgit@github.com:mbj/mutant (fetch)
              origin\tgit@github.com:mbj/mutant (push)
              origin\tgit@github.com:mbj/unparser (fetch)
              origin\tgit@github.com:mbj/unparser (push)
            REMOTE
          end

          let(:subscription) do
            Mutant::License::Subscription::Commercial::Organization.new(
              licensed: [
                Mutant::License::Subscription::Repository.new(
                  host: 'github.com',
                  path: 'mbj/mutant'
                ),
                Mutant::License::Subscription::Repository.new(
                  host: 'github.com',
                  path: 'mbj/something'
                )
              ].to_set
            )
          end

          it_is_successful
        end

        context 'when repository is not whitelisted' do
          let(:allowed_repositories) { %w[gitlab.com/mbj/mutant] }

          it_fails_with_message(<<~'MESSAGE')
            Can not validate commercial organization license.
            Licensed:
            gitlab.com/mbj/mutant
            Present:
            github.com/mbj/mutant
          MESSAGE
        end
      end

      shared_examples 'individual licenses' do
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

        let(:commands) do
          {
            %w[git config --get user.email]          => git_config_result,
            %w[git show --quiet --pretty=format:%ae] => git_show_result
          }
        end

        let(:subscription) do
          Mutant::License::Subscription::Commercial::Individual.new(
            licensed: licensed_authors
              .to_set { |email| Mutant::License::Subscription::Commercial::Individual::Author.new(email: email) }
          )
        end

        context 'when author is whitelisted' do
          it_is_successful
        end

        context 'when author is not whitelisted' do
          let(:licensed_authors) { %w[customer-c@example.com] }

          it_fails_with_message(<<~'MESSAGE')
            Can not validate commercial individual license.
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
            Can not validate commercial individual license.
            Licensed:
            customer-a@example.com
            customer-b@example.com
            Present:
            [none]
          MESSAGE
        end
      end

      context 'on individual license' do
        context 'via legacy contents missing type field' do
          let(:license_json) do
            {
              'type'     => 'com',
              'contents' => {
                'authors' => licensed_authors
              }
            }
          end

          include_examples 'individual licenses'
        end

        context 'via contents type field' do
          let(:license_json) do
            {
              'type'     => 'com',
              'contents' => {
                'type'    => 'individual',
                'authors' => licensed_authors
              }
            }
          end

          include_examples 'individual licenses'
        end
      end
    end
  end
end
