# frozen_string_literal: true

describe Mutant::Repository::Diff::Ranges do
  describe '.parse' do
    def apply
      described_class.parse(diff)
    end

    let(:diff) do
      Tempfile.open('old') do |old_file|
        old_file.write(old)
        old_file.flush
        Tempfile.open('new') do |new_file|
          new_file.write(new)
          new_file.flush
          # rubocop:disable Lint/RedundantSplatExpansion
          stdout, status = Open3.capture2(
            *%W[
              git
              diff
              --no-index
              --unified=0
              --
              #{old_file.path}
              #{new_file.path}
            ]
          )
          # rubocop:enable Lint/RedundantSplatExpansion

          fail unless [0, 256].include?(status.to_i)

          stdout
        end
      end
    end

    context 'on empty diff' do
      let(:old) { '' }
      let(:new) { '' }

      it 'returns emtpy set' do
        expect(apply).to eql(Set.new)
      end
    end

    context 'on empty old' do
      let(:old) { '' }

      context 'adding a single line' do
        let(:new) do
          <<~'STR'
            a
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([1..1].to_set)
        end
      end

      context 'adding a multiple lines' do
        let(:old) { '' }

        let(:new) do
          <<~'STR'
            a
            b
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([1..2].to_set)
        end
      end
    end

    context 'on empty new' do
      let(:new) { '' }

      context 'removing a single line' do
        let(:old) do
          <<~'STR'
            a
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([1..1].to_set)
        end
      end

      context 'removing a multiple lines' do
        let(:old) do
          <<~'STR'
            a
            b
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([1..2].to_set)
        end
      end
    end

    context 'single line modification' do
      let(:old) do
        <<~'STR'
          a
          b
          c
          a
        STR
      end

      let(:new) do
        <<~'STR'
          a
          b
          b
          a
        STR
      end

      it 'returns expected set' do
        expect(apply).to eql([3..3].to_set)
      end
    end

    context 'nonempty old and new' do
      context 'single line addition' do
        let(:old) do
          <<~'STR'
            a
            b
            a
          STR
        end

        let(:new) do
          <<~'STR'
            a
            b
            b
            a
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([3..3].to_set)
        end
      end
      context 'multi line modification' do
        let(:old) do
          <<~'STR'
            a
            b
            c
            d
            a
          STR
        end

        let(:new) do
          <<~'STR'
            a
            b
            b
            b
            a
          STR
        end

        it 'returns expected set' do
          expect(apply).to eql([3..4].to_set)
        end
      end
    end
  end
end
