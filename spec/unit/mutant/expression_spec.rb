RSpec.describe Mutant::Expression do
  let(:parser) { Mutant::Config::DEFAULT.expression_parser }

  describe '#prefix?' do
    let(:object) { parser.call('Foo*') }

    subject { object.prefix?(other) }

    context 'when object is a prefix of other' do
      let(:other) { parser.call('Foo::Bar') }

      it { should be(true) }
    end

    context 'when other is not a prefix of other' do
      let(:other) { parser.call('Bar') }

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
