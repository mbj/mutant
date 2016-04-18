RSpec.describe Mutant::AST::Regexp::Transformer::LookupTable do
  subject(:pair) { mapper.new(s(:regexp_fake)).pair }

  let(:table) { instance_double(described_class::Table) }
  let(:token) { ::Regexp::Token.new  }
  let(:klass) { ::Regexp::Expression }

  let(:mapping) do
    described_class::Mapping.new(token, klass)
  end

  let(:mapper) do
    fake_table = table

    Class.new do
      include Concord.new(:node), Mutant::AST::Regexp::Transformer::LookupTable

      const_set(:TABLE, fake_table)

      def pair
        [expression_token, expression_class]
      end
    end
  end

  before do
    allow(table).to receive(:lookup).with(:regexp_fake).and_return(mapping)
  end

  it 'constructs regexp lookup table' do
    expect(pair).to eql([token, klass])
  end
end
