# rubocop:disable ClassAndModuleChildren
RSpec.describe Mutant::Matcher::Method::Singleton, '#each' do
  subject { object.each(&yields.method(:<<)) }

  let(:object)       { described_class.new(env, scope, method) }
  let(:method)       { scope.method(method_name)               }
  let(:env)          { Fixtures::TEST_ENV                      }
  let(:yields)       { []                                      }
  let(:type)         { :defs                                   }
  let(:method_name)  { :foo                                    }
  let(:method_arity) { 0                                       }
  let(:base)         { TestApp::SingletonMethodTests           }

  def name
    node.children[1]
  end

  def arguments
    node.children[2]
  end

  context 'on singleton methods' do

    context 'when also defined on lvar' do
      let(:scope)       { base::AlsoDefinedOnLvar }
      let(:method_line) { 66                      }

      it_should_behave_like 'a method matcher'

      it 'warns about definition on non const/self' do
        subject
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
        let(:method_line) { 78                                        }
        let(:scope)       { base::DefinedOnConstant::OutsideNamespace }

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
    end
  end
end
