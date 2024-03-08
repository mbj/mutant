# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method::Singleton, '#call' do
  subject { object.call(env) }

  let(:object)       { described_class.new(scope: scope, target_method: method) }
  let(:method)       { scope.raw.method(method_name)                            }
  let(:type)         { :defs                                                    }
  let(:method_name)  { :foo                                                     }
  let(:method_arity) { 0                                                        }
  let(:base)         { TestApp::SingletonMethodTests                            }
  let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb')        }

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
      world:  world
    )
  end

  def name
    node.children.fetch(1)
  end

  def arguments
    node.children.fetch(2)
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
        'Can only match :defs on :self or :const got :lvar unable to match'
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when defined on self' do
    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        base::DefinedOnSelf
      )
    end

    let(:method_line) { 61 }

    it_should_behave_like 'a method matcher' do
      %i[public protected private].each do |visibility|
        context 'with %s visibility' % visibility do
          before do
            scope.raw.singleton_class.__send__(visibility, method_name)
          end

          it 'returns expected subjects' do
            expect(subject).to eql([mutation_subject.with(visibility: visibility)])
          end
        end
      end
    end
  end

  context 'when defined on constant' do
    context 'inside namespace' do
      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedOnConstant::InsideNamespace
        )
      end

      let(:method_line) { 71 }

      it_should_behave_like 'a method matcher'
    end

    context 'outside namespace' do
      let(:method_line) { 78 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedOnConstant::OutsideNamespace
        )
      end

      it_should_behave_like 'a method matcher'
    end
  end

  context 'when defined multiple times in the same line' do
    context 'with method on different scope' do
      let(:method_line)  { 97 }
      let(:method_arity) { 1  }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedMultipleTimes::SameLine::DifferentScope
        )
      end

      it_should_behave_like 'a method matcher'
    end

    context 'with different name' do
      let(:method_line) { 101 }

      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        base::DefinedMultipleTimes::SameLine::DifferentName
        )
      end

      it_should_behave_like 'a method matcher'
    end
  end

  context 'with sorbet signature' do
    let(:method_line)  { 126 }
    let(:method_arity) { 0   }

    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        base::WithSignature
      )
    end

    it_should_behave_like 'a method matcher'
  end

  context 'on inline disabled method' do
    let(:method_line)  { 152 }
    let(:method_arity) { 0   }

    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        TestApp::InlineDisabled
      )
    end

    it_should_behave_like 'a method matcher' do
      it 'returns disabled inline config' do
        expect(mutation_subject.config.inline_disable).to be(true)
      end
    end
  end
end
