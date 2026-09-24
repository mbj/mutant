# frozen_string_literal: true

RSpec.describe Mutant::Config::Selection do
  describe '#merge' do
    def apply
      original.merge(other)
    end

    let(:original) { described_class.new(path: nil, strategy: nil) }

    %i[path strategy].each do |key|
      context "for #{key} attribute" do
        context 'when original is not nil' do
          let(:original) { super().with(key => 'original') }

          context 'and other is nil' do
            let(:other) { described_class::DEFAULT }

            it 'returns original value' do
              expect(apply.public_send(key)).to eql('original')
            end
          end

          context 'and other is not nil' do
            let(:other) { described_class::DEFAULT.with(key => 'other') }

            it 'returns other value' do
              expect(apply.public_send(key)).to eql('other')
            end
          end
        end

        context 'when original is nil' do
          context 'and other is nil' do
            let(:other) { described_class::DEFAULT }

            it 'returns nil' do
              expect(apply.public_send(key)).to be(nil)
            end
          end

          context 'and other is not nil' do
            let(:other) { described_class::DEFAULT.with(key => 'other') }

            it 'returns other value' do
              expect(apply.public_send(key)).to eql('other')
            end
          end
        end
      end
    end
  end

  describe '#context_map?' do
    def apply
      object.context_map?
    end

    context 'on the context map strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'context_map') }

      it { expect(apply).to be(true) }
    end

    context 'on the expression strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'expression') }

      it { expect(apply).to be(false) }
    end

    context 'on the default strategy' do
      let(:object) { described_class::DEFAULT }

      it { expect(apply).to be(false) }
    end
  end

  describe '#expression?' do
    def apply
      object.expression?
    end

    context 'on the expression strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'expression') }

      it { expect(apply).to be(true) }
    end

    context 'on the context map strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'context_map') }

      it { expect(apply).to be(false) }
    end

    context 'on the auto strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'auto') }

      it { expect(apply).to be(false) }
    end

    context 'on the default strategy' do
      let(:object) { described_class::DEFAULT }

      it { expect(apply).to be(false) }
    end
  end

  describe '#effective_path' do
    def apply
      object.effective_path
    end

    context 'without configured path' do
      let(:object) { described_class::DEFAULT }

      it 'returns the conventional coverage directory' do
        expect(apply).to eql('coverage')
      end
    end

    context 'with configured path' do
      let(:object) { described_class::DEFAULT.with(path: 'tmp/coverage') }

      it 'returns the configured path' do
        expect(apply).to eql('tmp/coverage')
      end
    end
  end

  describe '#validate' do
    def apply
      object.validate
    end

    context 'without strategy' do
      let(:object) { described_class::DEFAULT }

      it { expect(apply).to eql(right(object)) }
    end

    described_class::STRATEGIES.each do |strategy|
      context "on known strategy #{strategy}" do
        let(:object) { described_class::DEFAULT.with(strategy:) }

        it { expect(apply).to eql(right(object)) }
      end
    end

    context 'on unknown strategy' do
      let(:object) { described_class::DEFAULT.with(strategy: 'unknown') }

      it 'returns expected error' do
        expect(apply).to eql(
          left('Unknown test selection strategy "unknown", expected one of: auto, expression, context_map')
        )
      end
    end
  end

  describe '::TRANSFORM' do
    def apply
      described_class::TRANSFORM.call(input)
    end

    context 'on empty configuration' do
      let(:input) { {} }

      it { expect(apply).to eql(right(described_class::DEFAULT)) }
    end

    context 'on full configuration' do
      let(:input) { { 'path' => 'tmp/coverage', 'strategy' => 'context_map' } }

      it 'returns expected configuration' do
        expect(apply).to eql(right(described_class.new(path: 'tmp/coverage', strategy: 'context_map')))
      end
    end

    context 'on unknown strategy' do
      let(:input) { { 'strategy' => 'unknown' } }

      it 'returns expected error' do
        expect(apply.from_left.compact_message).to eql(
          'Mutant::Transform::Sequence/2/selection: ' \
          'Unknown test selection strategy "unknown", expected one of: auto, expression, context_map'
        )
      end
    end
  end
end
