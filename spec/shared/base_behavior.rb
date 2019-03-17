# frozen_string_literal: true

RSpec.shared_examples 'no block evaluation' do
  context 'with block' do
    let(:block) { -> { fail } }

    it 'does not evaluate block' do
      apply
    end
  end
end

RSpec.shared_examples 'requires block' do
  context 'without block' do
    let(:block) { nil }

    specify do
      expect { apply }.to raise_error(LocalJumpError)
    end
  end
end

RSpec.shared_examples 'returns self' do
  it 'returns self' do
    expect(apply).to be(subject)
  end
end

RSpec.shared_examples '#apply block evaluation' do
  it 'evaluates block and returns its wrapped result' do
    expect { expect(apply).to eql(block_result) }
      .to change(yields, :to_a)
      .from([])
      .to([value])
  end
end

RSpec.shared_examples 'Functor#fmap block evaluation' do
  it 'evaluates block and returns its wrapped result' do
    expect { expect(apply).to eql(described_class.new(block_result)) }
      .to change(yields, :to_a)
      .from([])
      .to([value])
  end
end
