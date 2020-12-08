# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method::Instance, '#call' do
  subject { object.call(env) }

  let(:base)          { TestApp::InstanceMethodTests                      }
  let(:method)        { scope.instance_method(method_name)                }
  let(:method_arity)  { 0                                                 }
  let(:method_name)   { :foo                                              }
  let(:object)        { described_class.new(scope, method)                }
  let(:source_path)   { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
  let(:type)          { :def                                              }
  let(:warnings)      { instance_double(Mutant::Warnings)                 }

  let(:world) do
    instance_double(
      Mutant::World,
      pathname: Pathname,
      warnings: warnings
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
    node.children.fetch(0)
  end

  def arguments
    node.children.fetch(1)
  end

  context 'when method is defined inside eval' do
    let(:scope)  { base::WithMemoizer                                 }
    let(:method) { scope.instance_method(:boz)                        }

    let(:expected_warnings) do
      [
        "#{method} does not have a valid source location, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'

    it 'returns expected subjects' do
      expect(subject).to eql([])
    end
  end

  context 'when method is defined without source location' do
    let(:scope)  { Module                            }
    let(:method) { scope.instance_method(:object_id) }

    let(:expected_warnings) do
      [
        "#{method} does not have a valid source location, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'

    it 'returns expected subjects' do
      expect(subject).to eql([])
    end
  end

  context 'in module eval' do
    let(:scope) { base::InModuleEval }

    let(:expected_warnings) do
      [
        "#{method} is dynamically defined in a closure, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'

    it 'returns expected subjects' do
      expect(subject).to eql([])
    end
  end

  context 'in class eval' do
    let(:scope) { base::InClassEval }

    let(:expected_warnings) do
      [
        "#{method} is dynamically defined in a closure, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'

    it 'returns expected subjects' do
      expect(subject).to eql([])
    end
  end

  context 'when method is defined once' do
    let(:method_name) { :bar               }
    let(:scope)       { base::WithMemoizer }
    let(:method_line) { 13                 }

    it_should_behave_like 'a method matcher'

    it 'returns expected subjects' do
      context = Mutant::Context.new(
        TestApp::InstanceMethodTests::WithMemoizer,
        MutantSpec::ROOT.join('test_app', 'lib', 'test_app.rb')
      )

      expect(subject).to eql(
        [
          Mutant::Subject::Method::Instance.new(
            context:  context,
            node:     s(:def, :bar, s(:args), nil),
            warnings: warnings
          )
        ]
      )
    end
  end

  context 'when method is defined once with a memoizer' do
    let(:scope)       { base::WithMemoizer }
    let(:method_line) { 15                 }

    it_should_behave_like 'a method matcher'
  end

  context 'when method is defined multiple times' do
    context 'on different lines' do
      let(:scope)        { base::DefinedMultipleTimes::DifferentLines }
      let(:method_line)  { 24                                         }
      let(:method_arity) { 1                                          }

      it_should_behave_like 'a method matcher'
    end

    context 'on the same line' do
      let(:scope)        { base::DefinedMultipleTimes::SameLineSameScope }
      let(:method_line)  { 29                                            }
      let(:method_arity) { 1                                             }

      it_should_behave_like 'a method matcher'
    end

    context 'on the same line with different scope' do
      let(:scope)        { base::DefinedMultipleTimes::SameLineDifferentScope }
      let(:method_line)  { 33                                                 }
      let(:method_arity) { 1                                                  }

      it_should_behave_like 'a method matcher'
    end
  end
end
