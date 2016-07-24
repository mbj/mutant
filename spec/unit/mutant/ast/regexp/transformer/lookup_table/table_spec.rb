RSpec.describe Mutant::AST::Regexp::Transformer::LookupTable::Table do
  subject { table.lookup(:regexp_fake_thing) }

  let(:expression_class) { class_double(Regexp::Expression) }

  let(:table) do
    described_class.create(
      [:regexp_fake_thing, %i[thing fake], expression_class]
    )
  end

  its(:token) { should eql(Regexp::Token.new(:thing, :fake)) }

  its(:regexp_class) { should be(expression_class) }

  it 'exposes list of types' do
    expect(table.types).to eql([:regexp_fake_thing])
  end
end
