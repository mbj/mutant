RSpec.describe Mutant::Matcher::Method::Instance, '#call' do
  subject { object.call(env) }

  let(:env)          { Fixtures::TEST_ENV                                }
  let(:reporter)     { Fixtures::TEST_CONFIG.reporter                    }
  let(:method_name)  { :foo                                              }
  let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
  let(:object)       { described_class.new(scope, method)                }
  let(:method)       { scope.instance_method(method_name)                }
  let(:namespace)    { self.class                                        }
  let(:type)         { :def                                              }
  let(:method_arity) { 0                                                 }
  let(:base)         { TestApp::InstanceMethodTests                      }

  def name
    node.children.fetch(0)
  end

  def arguments
    node.children.fetch(1)
  end

  shared_examples_for 'skipped candidate' do
    it 'does not emit matcher' do
      expect(subject).to eql([])
    end

    it 'does warn' do
      subject
      expect(reporter.warn_calls.last).to(
        eql("#{method} does not have valid source location, unable to emit subject")
      )
    end
  end

  context 'when method is defined inside eval' do
    let(:scope)       { base::WithMemoizer          }
    let(:method)      { scope.instance_method(:boz) }
    let(:method_name) { :boz                        }

    include_examples 'skipped candidate'
  end

  context 'when method is defined without source location' do
    let(:scope)  { Module                            }
    let(:method) { scope.instance_method(:object_id) }

    include_examples 'skipped candidate'
  end

  context 'when method is defined once' do
    let(:method_name) { :bar               }
    let(:scope)       { base::WithMemoizer }
    let(:method_line) { 13                 }

    it_should_behave_like 'a method matcher'
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

    context 'in module eval' do
      let(:scope) { base::InModuleEval }

      it 'does not emit matcher' do
        expect(subject).to eql([])
      end

      it 'does warn' do
        subject
        expect(reporter.warn_calls.last).to(
          eql("#{method} is dynamically defined in a closure, unable to emit subject")
        )
      end
    end

    context 'in class eval' do
      let(:scope) { base::InClassEval }

      it 'does not emit matcher' do
        expect(subject).to eql([])
      end

      it 'does warn' do
        subject
        expect(reporter.warn_calls.last).to(
          eql("#{method} is dynamically defined in a closure, unable to emit subject")
        )
      end
    end
  end
end
