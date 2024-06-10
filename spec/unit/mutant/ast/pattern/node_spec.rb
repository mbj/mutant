# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Node do
  describe '#syntax' do
    def apply
      instance.syntax
    end

    let(:descendant) do
      described_class::Descendant.new(
        name:    :receiver,
        pattern: described_class.new(type: :int)
      )
    end

    let(:attribute) do
      described_class::Attribute.new(
        name:  :selector,
        value: described_class::Attribute::Value::Single.new(value: :foo)
      )
    end

    context 'on only type' do
      let(:instance) do
        described_class.new(type: :send)
      end

      it 'returns expected value' do
        expect(apply).to eql('send')
      end
    end

    context 'with attribute' do
      let(:instance) do
        described_class.new(
          type:      :send,
          attribute:
        )
      end

      context 'with single value' do
        it 'returns expected value' do
          expect(apply).to eql('send{selector=foo}')
        end
      end

      context 'with group value' do
        let(:attribute) do
          described_class::Attribute.new(
            name:  :selector,
            value: described_class::Attribute::Value::Group.new(
              values: [
                described_class::Attribute::Value::Single.new(value: :a),
                described_class::Attribute::Value::Single.new(value: :b)
              ]
            )
          )
        end

        it 'returns expected value' do
          expect(apply).to eql('send{selector=(a,b)}')
        end
      end
    end

    context 'with descendant' do
      let(:instance) do
        described_class.new(
          type:       :send,
          descendant:
        )
      end

      let(:descendant) do
        described_class::Descendant.new(
          name:    :receiver,
          pattern: described_class.new(type: :int)
        )
      end

      it 'returns expected value' do
        expect(apply).to eql('send{receiver=int}')
      end
    end

    context 'with attribute and descendant' do
      let(:instance) do
        described_class.new(
          type:       :send,
          attribute:,
          descendant:
        )
      end

      it 'returns expected value' do
        expect(apply).to eql('send{selector=foo receiver=int}')
      end
    end
  end

  describe '#match?' do
    def apply
      instance.match?(node)
    end

    context 'on only type pattern' do
      let(:instance) do
        described_class.new(type: :str)
      end

      context 'on mismatch' do
        let(:node) { s(:int, 1) }

        it 'returns false' do
          expect(apply).to be(false)
        end
      end

      context 'on match' do
        let(:node) { s(:str, 1) }

        it 'returns true' do
          expect(apply).to be(true)
        end
      end
    end

    context 'attribute pattern' do
      let(:instance) do
        described_class.new(
          type:      :str,
          attribute:
        )
      end

      context 'single attribute value' do
        let(:attribute) do
          described_class::Attribute.new(
            name:  :value,
            value: described_class::Attribute::Value::Single.new(
              value: '1'
            )
          )
        end

        context 'on mismatch' do
          let(:node) { s(:str, '2') }

          it 'returns false' do
            expect(apply).to be(false)
          end
        end

        context 'on match' do
          let(:node) { s(:str, '1') }

          it 'returns true' do
            expect(apply).to be(true)
          end
        end
      end

      context 'group attribute value' do
        let(:attribute) do
          described_class::Attribute.new(
            name:  :value,
            value: described_class::Attribute::Value::Group.new(
              values: [
                described_class::Attribute::Value::Single.new(value: '1'),
                described_class::Attribute::Value::Single.new(value: '2')
              ]
            )
          )
        end

        context 'on mismatch' do
          let(:node) { s(:str, '3') }

          it 'returns false' do
            expect(apply).to be(false)
          end
        end

        context 'on match on first group element' do
          let(:node) { s(:str, '1') }

          it 'returns true' do
            expect(apply).to be(true)
          end
        end

        context 'on match on last group element' do
          let(:node) { s(:str, '2') }

          it 'returns true' do
            expect(apply).to be(true)
          end
        end
      end
    end

    context 'descendant pattern' do
      let(:instance) do
        described_class.new(
          type:       :send,
          descendant: described_class::Descendant.new(
            name:    :receiver,
            pattern: described_class.new(type: :const)
          )
        )
      end

      context 'on mismatch' do
        context 'when descendant node is present' do
          let(:node) { s(:send, s(:int, 1), :foo) }

          it 'returns false' do
            expect(apply).to be(false)
          end
        end

        context 'when descendant node is absent' do
          let(:node) { s(:send, nil, :foo) }

          it 'returns false' do
            expect(apply).to be(false)
          end
        end
      end

      context 'on match' do
        let(:node) { s(:send, s(:const, nil, :Foo), :foo) }

        it 'returns true' do
          expect(apply).to be(true)
        end
      end
    end

    context 'variable pattern' do
      let(:instance) do
        described_class.new(
          type:     :send,
          variable: Object.new
        )
      end

      let(:node) { s(:send, nil, :foo, s(:int, 1)) }

      it 'raises not implemented error' do
        expect { apply }.to raise_error(NotImplementedError)
      end
    end
  end
end
