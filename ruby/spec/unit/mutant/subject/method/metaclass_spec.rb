# frozen_string_literal: true

RSpec.describe Mutant::Subject::Method::Metaclass do
  let(:object) do
    described_class.new(
      config:     Mutant::Subject::Config::DEFAULT,
      context:,
      node:,
      visibility: :public
    )
  end

  let(:node) { s(:def, :foo, s(:args)) }

  let(:constant_scope) do
    Mutant::Context::ConstantScope::None.new
  end

  let(:context) do
    Mutant::Context.new(
      constant_scope:,
      scope:,
      source_path:    instance_double(Pathname)
    )
  end

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        Class.new do
          class << self
            def foo; end

            def name
              'Test'
            end
          end
                  end
    )
  end

  describe '#expression' do
    subject { object.expression }

    it { should eql(parse_expression('Test.foo')) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#match_expression' do
    subject { object.match_expressions }

    it { should eql(%w[Test.foo Test*].map(&method(:parse_expression))) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#prepare' do

    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }.to change { scope.raw.public_methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql("class << self\n  def foo\n  end\nend\n") }
  end
end
