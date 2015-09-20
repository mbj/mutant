RSpec.describe Mutant::Expression do
  let(:object) { described_class }

  describe '#prefix?' do
    let(:object) { parse_expression('Foo*') }

    subject { object.prefix?(other) }

    context 'when object is a prefix of other' do
      let(:other) { parse_expression('Foo::Bar') }

      it { should be(true) }
    end

    context 'when other is not a prefix of other' do
      let(:other) { parse_expression('Bar') }

      it { should be(false) }
    end
  end

  describe '.try_parse' do
    let(:object) do
      Class.new(described_class) do
        include Anima.new(:foo)

        const_set(:REGEXP, /(?<foo>foo)/)
      end
    end

    subject { object.try_parse(input) }

    context 'on successful parse' do
      let(:input) { 'foo' }

      it { should eql(object.new(foo: 'foo')) }
    end

    context 'on unsuccessful parse' do
      let(:input) { 'bar' }

      it { should be(nil) }
    end
  end
end
