# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method::Metaclass, '#call' do
  source_path = 'test_app/lib/test_app/metaclasses.rb'

  subject { object.call(env) }

  let(:object)       { described_class.new(scope:, target_method: method) }
  let(:method)       { scope.raw.public_method(method_name)                     }
  let(:type)         { :def                                                     }
  let(:method_name)  { :foo                                                     }
  let(:method_arity) { 0                                                        }
  let(:base)         { TestApp::MetaclassMethodTests                            }
  let(:source_path)  { MutantSpec::ROOT.join(source_path)                       }

  let(:world) do
    instance_double(
      Mutant::World,
      pathname: Pathname
    )
  end

  let(:env) do
    instance_double(
      Mutant::Env,
      config: Mutant::Config::DEFAULT,
      parser: Fixtures::TEST_ENV.parser,
      world:
    )
  end

  def name
    node.children.fetch(0)
  end

  def arguments
    node.children.fetch(1)
  end

  context 'when also defined on lvar' do
    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        base::DefinedOnLvar
      )
    end

    let(:expected_warnings) do
      [
        'Can only match :def inside :sclass on :self or :const, got :sclass on :lvar unable to match'
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when defined on self' do
    let(:method_line) { 7 }

    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        base::DefinedOnSelf
      )
    end

    it_behaves_like 'a method matcher'

    context 'when scope is a metaclass' do
      let(:method_line) { 28 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedOnSelf::InsideMetaclass.metaclass
        )
      end

      it_behaves_like 'a method matcher'
    end
  end

  context 'when defined on constant' do
    context 'inside namespace' do
      let(:method_line) { 44 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedOnConstant::InsideNamespace
        )
      end

      it_behaves_like 'a method matcher'
    end

    context 'outside namespace' do
      let(:method_line) { 52 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedOnConstant::OutsideNamespace
        )
      end

      it_behaves_like 'a method matcher'
    end
  end

  context 'when defined multiple times in the same line' do
    context 'with method on different scope' do
      let(:method_line)  { 76 }
      let(:method_arity) { 1  }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedMultipleTimes::SameLine::DifferentScope
        )
      end

      it_behaves_like 'a method matcher'
    end

    context 'with different name' do
      let(:method_line) { 80 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedMultipleTimes::SameLine::DifferentName
        )
      end

      it_behaves_like 'a method matcher'
    end
  end

  # tests that the evaluator correctly returns nil when the metaclass doesn't
  # directly contain the method
  context 'when defined inside a class in a metaclass' do
    let(:method) { scope.raw.metaclass::SomeClass.new.public_method(:foo) }

    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        base::NotActuallyInAMetaclass
      )
    end

    it { is_expected.to be_empty }
  end
end
