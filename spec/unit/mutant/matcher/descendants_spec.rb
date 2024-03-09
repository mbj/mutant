# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Descendants do
  let(:env) { Fixtures::TEST_ENV }

  describe '#call' do
    subject { described_class.new(const_name: const_name) }

    def apply
      subject.call(env)
    end

    let(:constant_scope) do
      Mutant::Context::ConstantScope::Module.new(
        const:      s(:const, nil, :TestApp),
        descendant: Mutant::Context::ConstantScope::Class.new(
          const:      s(:const, nil, :Foo),
          descendant: Mutant::Context::ConstantScope::Class.new(
            const:      s(:const, nil, :Bar),
            descendant: Mutant::Context::ConstantScope::Class.new(
              const:      s(:const, nil, :Baz),
              descendant: Mutant::Context::ConstantScope::None.new
            )
          )
        )
      )
    end

    let(:expected_subjects) do
      [
        Mutant::Subject::Method::Instance.new(
          config:     Mutant::Subject::Config::DEFAULT,
          context:    Mutant::Context.new(
            constant_scope: constant_scope,
            scope:          Mutant::Scope.new(
              raw:        TestApp::Foo::Bar::Baz,
              expression: parse_expression('TestApp::Foo::Bar::Baz')
            ),
            source_path:    TestApp::ROOT.join('lib/test_app.rb')
          ),
          node:       s(:def, :foo, s(:args), nil),
          visibility: :public
        )
      ]
    end

    context 'on unknown const name' do
      let(:const_name) { 'TestApp::Unknown' }

      it 'returns empty matches' do
        expect(apply).to eql([])
      end
    end

    context 'on known descendant const name' do
      let(:const_name) { 'TestApp::Foo' }

      it 'returns expected matches' do
        expect(apply).to eql(expected_subjects)
      end
    end

    context 'on exact const name' do
      let(:const_name) { 'TestApp::Foo::Bar::Baz' }

      it 'returns expected matches' do
        expect(apply).to eql(expected_subjects)
      end
    end
  end
end
