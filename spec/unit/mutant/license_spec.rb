# frozen_string_literal: true

RSpec.describe Mutant::License do
  def apply
    described_class.apply(world)
  end

  let(:gem)              { class_double(Gem, loaded_specs: loaded_specs) }
  let(:gem_method)       { instance_double(Method)                       }
  let(:gem_path)         { '/path/to/mutant-license'                     }
  let(:gem_pathname)     { instance_double(Pathname)                     }
  let(:json)             { class_double(JSON)                            }
  let(:kernel)           { class_double(Kernel)                          }
  let(:license_pathname) { instance_double(Pathname)                     }
  let(:load_json)        { true                                          }
  let(:loaded_specs)     { { 'mutant-license' => spec }                  }
  let(:path)             { instance_double(Pathname)                     }
  let(:pathname)         { class_double(Pathname)                        }
  let(:stderr)           { instance_double(IO)                           }

  let(:spec) do
    instance_double(
      Gem::Specification,
      full_gem_path: gem_path
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      gem:        gem,
      gem_method: gem_method,
      json:       json,
      kernel:     kernel,
      pathname:   pathname,
      stderr:     stderr
    )
  end

  before do
    allow(gem_method).to receive_messages(call: undefined)
    allow(gem_pathname).to receive_messages(join: license_pathname)
    allow(json).to receive_messages(load: license_json)
    allow(kernel).to receive_messages(sleep: undefined)
    allow(pathname).to receive_messages(new: gem_pathname)
    allow(world).to receive(:capture_stdout, &commands.method(:fetch))
  end

  def self.it_fails(expected)
    it 'failse with exception' do
      expect { apply }.to raise_error(expected)
    end
  end

  def self.it_is_successful
    include_examples 'license.json lookup'

    it 'allows usage' do
      expect(apply).to eql(Mutant::Either::Right.new(true))
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.it_fails_with_message(expected)
    before do
      allow(stderr).to receive(:puts)
    end

    it 'performs IO in expected sequence' do
      expect(apply).to eql(Mutant::Either::Right.new(true))

      expect(gem_method)
        .to have_received(:call)
        .with('mutant-license', '~> 0.1.0')
        .ordered

      if load_json
        expect(json)
          .to have_received(:load)
          .with(license_pathname)
          .ordered
      end

      expect(stderr)
        .to have_received(:puts)
        .with(expected)
        .ordered

      expect(stderr)
        .to have_received(:puts)
        .with('[Mutant-License-Error]: Soft fail, continuing in 20 seconds')
        .ordered

      expect(stderr)
        .to have_received(:puts)
        .with('[Mutant-License-Error]: Next major version will enforce the license')
        .ordered

      expect(stderr)
        .to have_received(:puts)
        .with('[Mutant-License-Error]: See https://github.com/mbj/mutant#licensing')
        .ordered

      expect(kernel)
        .to have_received(:sleep)
        .with(20)
        .ordered
    end
  end

  shared_examples 'license.json lookup' do
    it 'builds correct license.json path' do
      apply

      expect(pathname).to have_received(:new).with(gem_path)
      expect(gem_pathname).to have_received(:join).with('license.json')
    end
  end

  describe 'on opensource license' do
    let(:repository) { 'github.com/mbj/mutant' }

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

    let(:git_remote_result) { Mutant::Either::Right.new(git_remote) }

    let(:commands) do
      {
        %w[git remote --verbose] => git_remote_result
      }
    end

    context 'when repository is whitelisted' do
      context 'on ssh url without protocol and without suffx' do
        it_is_successful
      end

      context 'on ssh url with protocol and without suffx' do
        let(:git_remote) do
          <<~REMOTE
            origin\tssh://git@github.com/mbj/mutant (fetch)
            origin\tssh://git@github.com/mbj/mutant (push)
          REMOTE
        end

        it_is_successful
      end

      context 'on ssh url with protocol and suffx' do
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

    context 'when git remote line cannot be parsed' do
      let(:git_remote) { "some-bad-remote-line\n" }

      it_fails 'Unmatched remote line: "some-bad-remote-line\n"'
    end

    context 'when git remote url cannot be parsed' do
      let(:git_remote) { "some-unknown\thttp://github.com/mbj/mutant (fetch)\n" }

      it_fails 'Unmatched git remote URL: "http://github.com/mbj/mutant"'
    end
  end

  describe 'on commercial license' do
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

    let(:git_config_author) { "customer-a@example.com\n"                   }
    let(:git_config_result) { Mutant::Either::Right.new(git_config_author) }
    let(:git_show_author)   { "customer-b@example.com\n"                   }
    let(:git_show_result)   { Mutant::Either::Right.new(git_show_author)   }

    let(:commands) do
      {
        %w[git config --get user.email]          => git_config_result,
        %w[git show --quiet --pretty=format:%ae] => git_show_result
      }
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

    context 'when mutant-license gem cannot be loaded' do
      let(:load_json) { false }

      before do
        allow(gem_method).to receive(:call).and_raise(Gem::LoadError, 'test-error')
      end

      it_fails_with_message '[Mutant-License-Error]: test-error'
    end
  end
end
