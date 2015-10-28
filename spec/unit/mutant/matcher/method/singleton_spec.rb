RSpec.describe Mutant::Matcher::Method::Singleton, '#call' do
  subject { object.call(env) }

  let(:object)       { described_class.new(scope, method)                }
  let(:method)       { scope.method(method_name)                         }
  let(:env)          { Fixtures::TEST_ENV                                }
  let(:type)         { :defs                                             }
  let(:method_name)  { :foo                                              }
  let(:method_arity) { 0                                                 }
  let(:base)         { TestApp::SingletonMethodTests                     }
  let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }

  def name
    node.children.fetch(1)
  end

  def arguments
    node.children.fetch(2)
  end

  context 'on singleton methods' do
    context 'when also defined on lvar' do
      let(:scope)        { base::DefinedOnLvar }
      let(:method_line)  { 66                  }

      it 'warns about definition on non const/self' do
        expect(subject).to eql([])
        expect(env.config.reporter.warn_calls).to(
          include('Can only match :defs on :self or :const got :lvar unable to match')
        )
      end
    end

    context 'when defined on self' do
      let(:scope)       { base::DefinedOnSelf }
      let(:method_line) { 61                  }

      it_should_behave_like 'a method matcher'
    end

    context 'when defined on constant' do
      context 'inside namespace' do
        let(:scope)       { base::DefinedOnConstant::InsideNamespace }
        let(:method_line) { 71                                       }

        it_should_behave_like 'a method matcher'
      end

      context 'outside namespace' do
        let(:scope)       { base::DefinedOnConstant::OutsideNamespace }
        let(:method_line) { 78                                        }

        it_should_behave_like 'a method matcher'
      end
    end

    context 'when defined multiple times in the same line' do
      context 'with method on different scope' do
        let(:scope)        { base::DefinedMultipleTimes::SameLine::DifferentScope }
        let(:method_line)  { 97                                                   }
        let(:method_arity) { 1                                                    }

        it_should_behave_like 'a method matcher'
      end

      context 'with different name' do
        let(:scope)        { base::DefinedMultipleTimes::SameLine::DifferentName }
        let(:method_line)  { 101                                                 }

        it_should_behave_like 'a method matcher'
      end
    end
  end
end
