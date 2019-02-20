# frozen_string_literal: true

RSpec.describe Mutant::Transform::Error do
  subject { described_class.new(attributes) }

  let(:message)        { 'root-message' }
  let(:direct_cause)   { nil            }
  let(:indirect_cause) { nil            }

  let(:attributes) do
    transform =
      if direct_cause
        Mutant::Transform::Named.new('root', direct_cause.transform)
      else
        Mutant::Transform::Boolean.new
      end

    {
      cause:     direct_cause,
      input:     nil,
      message:   message,
      transform: transform
    }
  end

  shared_context 'direct cause' do
    let(:direct_cause) do
      transform =
        if indirect_cause
          Mutant::Transform::Named.new('direct-cause', indirect_cause.transform)
        else
          Mutant::Transform::Boolean.new
        end

      described_class.new(
        cause:     indirect_cause,
        input:     nil,
        message:   'direct-cause-message',
        transform: transform
      )
    end
  end

  shared_examples 'indirect cause' do
    let(:indirect_cause) do
      described_class.new(
        cause:     nil,
        input:     nil,
        message:   'indirect-cause-message',
        transform: Mutant::Transform::Boolean.new
      )
    end
  end

  describe '#trace' do
    def apply
      subject.trace
    end

    context 'without cause' do
      it 'returns path to self' do
        expect(apply).to eql([subject])
      end
    end

    context 'with direct cause' do
      include_context 'direct cause'

      it 'returns path to direct cause' do
        expect(apply).to eql([subject, direct_cause])
      end
    end

    context 'with indirect cause' do
      include_context 'direct cause'
      include_context 'indirect cause'

      it 'returns path to direct cause' do
        expect(apply).to eql([subject, direct_cause, indirect_cause])
      end
    end
  end

  describe '#compact_message' do
    def apply
      subject.compact_message
    end

    context 'root cause' do
      it 'returns expected message' do
        expect(apply).to eql('Mutant::Transform::Boolean: root-message')
      end
    end

    context 'with direct cause' do
      include_context 'direct cause'

      it 'returns expected message' do
        expect(apply).to eql(<<~'MESSAGE'.chomp)
          root/Mutant::Transform::Boolean: direct-cause-message
        MESSAGE
      end
    end

    context 'with indirect cause' do
      include_context 'direct cause'
      include_context 'indirect cause'

      context 'with present slugs' do
        it 'returns expected message' do
          expect(apply).to eql(<<~'MESSAGE'.chomp)
            root/direct-cause/Mutant::Transform::Boolean: indirect-cause-message
          MESSAGE
        end
      end

      context 'with empty slug' do
        let(:direct_cause) do
          super().with(
            transform: Mutant::Transform::Named.new('', indirect_cause.transform)
          )
        end

        it 'returns expected message' do
          expect(apply).to eql(<<~'MESSAGE'.chomp)
            root/Mutant::Transform::Boolean: indirect-cause-message
          MESSAGE
        end
      end
    end
  end
end
