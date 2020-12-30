# frozen_string_literal: true

RSpec.describe Mutant::AST::Regexp::Transformer do
  before do
    stub_const("#{described_class}::REGISTRY", Mutant::Registry.new)
  end

  it 'registers types to a given class' do
    klass = Class.new(described_class) { register(:regexp_bos_anchor) }

    expect(described_class.lookup(:regexp_bos_anchor)).to be(klass)
  end

  it 'rejects duplicate registrations' do
    Class.new(described_class) { register(:regexp_bos_anchor) }

    expect { Class.new(described_class) { register(:regexp_bos_anchor) } }
      .to raise_error(Mutant::Registry::RegistryError)
      .with_message('Duplicate type registration: :regexp_bos_anchor')
  end
end
