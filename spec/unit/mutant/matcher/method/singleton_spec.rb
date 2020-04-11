# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method::Singleton, '#call' do
  subject { object.call(env) }

  let(:object)       { described_class.new(scope, method)                }
  let(:method)       { scope.method(method_name)                         }
  let(:type)         { :defs                                             }
  let(:method_name)  { :foo                                              }
  let(:method_arity) { 0                                                 }
  let(:base)         { TestApp::SingletonMethodTests                     }
  let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
  let(:warnings)     { instance_double(Mutant::Warnings)                 }

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
    node.children.fetch(1)
  end

  def arguments
    node.children.fetch(2)
  end

  context 'when also defined on lvar' do
    let(:scope) { base::DefinedOnLvar }
    let(:expected_warnings) do
      [
        'Can only match :defs on :self or :const got :lvar unable to match'
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when defined on self' do
    let(:scope)       { base::DefinedOnSelf }
    let(:method_line) { 61                  }

    it_should_behave_like 'a method matcher'
  end


  context 'when defined on constant' do
    context 'inside namespace' do
      let(:scope)       { base::DefinedOnConstant::InsideNamespace }
      let(:method_line) { 77                                       }

      it_should_behave_like 'a method matcher'
    end

    context 'outside namespace' do
      let(:scope)       { base::DefinedOnConstant::OutsideNamespace }
      let(:method_line) { 84                                        }

      it_should_behave_like 'a method matcher'
    end
  end

  context 'when defined multiple times in the same line' do
    context 'with method on different scope' do
      let(:scope)        { base::DefinedMultipleTimes::SameLine::DifferentScope }
      let(:method_line)  { 103                                                   }
      let(:method_arity) { 1                                                    }

      it_should_behave_like 'a method matcher'
    end

    context 'with different name' do
      let(:scope)        { base::DefinedMultipleTimes::SameLine::DifferentName }
      let(:method_line)  { 107                                                 }

      it_should_behave_like 'a method matcher'
    end
  end
end
