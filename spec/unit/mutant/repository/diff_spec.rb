# frozen_string_literal: true

describe Mutant::Repository::Diff do
  describe '#touches?' do
    def apply
      subject.touches?(path, line_range)
    end

    subject { described_class.new(world: world, to: 'to_rev') }

    let(:kernel)     { class_double(Kernel)        }
    let(:line_range) { 4..5                        }
    let(:path)       { Pathname.new('/foo/bar.rb') }
    let(:pathname)   { class_double(Pathname)      }

    let(:world) do
      instance_double(
        Mutant::World,
        kernel:   kernel,
        pathname: pathname
      )
    end

    let(:allowed_paths) do
      %w[/foo bar.rb baz.rb].to_h do |path|
        [path, Pathname.new(path)]
      end
    end

    let(:file_diff_expectations) { [] }

    let(:raw_expectations) do
      [
        {
          receiver:  world,
          selector:  :capture_stdout,
          arguments: [%w[git rev-parse --show-toplevel]],
          reaction:  { return: Mutant::Either::Right.new("/foo\n") }
        },
        {
          receiver:  world,
          selector:  :capture_stdout,
          arguments: [%w[git diff-index to_rev]],
          reaction:  { return: Mutant::Either::Right.new(index_stdout) }
        },
        *file_diff_expectations
      ]
    end

    before do
      allow(pathname).to receive(:new, &allowed_paths.public_method(:fetch))
    end

    context 'when file is not touched in the diff' do
      let(:index_stdout) { '' }

      it 'returns false' do
        verify_events { expect(apply).to be(false) }
      end
    end

    context 'when a diff-index line is invalid' do
      let(:index_stdout) { 'invalid-line' }

      it 'raises error' do
        expect { verify_events { apply } }
          .to raise_error(
            described_class::Error,
            'Invalid git diff-index line: invalid-line'
          )
      end
    end

    context 'when file is touched in the diff' do
      let(:index_stdout) do
        <<~STR
          :000000 000000 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 M\tbar.rb
          :000000 000000 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000 M\tbaz.rb
        STR
      end

      let(:file_diff_expectations) do
        [
          {
            receiver:  world,
            selector:  :capture_stdout,
            arguments: [%w[git diff --unified=0 to_rev -- /foo/bar.rb]],
            reaction:  { return: Mutant::Either::Right.new(diff_stdout) }
          }
        ]
      end

      context 'and diff touches the line range' do
        let(:diff_stdout) do
          <<~'DIFF'
            --- bar.rb
            +++ bar.rb
            @@ -4 +4 @@ header
            -a
            +b
          DIFF
        end

        it 'returns true' do
          verify_events { expect(apply).to be(true) }
        end
      end

      context 'and diff does not touch the line range' do
        let(:diff_stdout) do
          <<~'DIFF'
            --- bar.rb
            +++ bar.rb
            @@ -3 +3 @@ header
            -a
            +b
          DIFF
        end

        it 'returns false' do
          verify_events { expect(apply).to be(false) }
        end
      end
    end
  end
end
