RSpec.describe Mutant::Matcher::Method::Instance do

  let(:env)      { Fixtures::TEST_ENV             }
  let(:reporter) { Fixtures::TEST_CONFIG.reporter }

  describe '#each' do
    subject { object.each(&yields.method(:<<)) }

    let(:object)       { described_class.build(env, scope, method) }
    let(:method)       { scope.instance_method(method_name)        }
    let(:yields)       { []                                        }
    let(:namespace)    { self.class                                }
    let(:type)         { :def                                      }
    let(:method_name)  { :foo                                      }
    let(:method_arity) { 0                                         }
    let(:base)         { TestApp::InstanceMethodTests              }

    def name
      node.children[0]
    end

    def arguments
      node.children[1]
    end

    context 'when method is defined without source location' do
      let(:scope) { Module }
      let(:method) { scope.instance_method(:object_id) }

      it 'does not emit matcher' do
        subject
        expect(yields.length).to be(0)
      end

      it 'does warn' do
        subject
        expect(reporter.warn_calls.last).to(
          eql("#{method.inspect} does not have valid source location unable to emit subject")
        )
      end
    end

    context 'when method is defined once' do
      let(:scope)       { base::DefinedOnce                                 }
      let(:source_path) { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
      let(:method_line) { 10                                                }

      it_should_behave_like 'a method matcher'
    end

    context 'when method is defined once with a memoizer' do
      let(:scope)       { base::WithMemoizer                                }
      let(:source_path) { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
      let(:method_line) { 15                                                }

      it_should_behave_like 'a method matcher'
    end

    context 'when method is defined multiple times' do
      context 'on different lines' do
        let(:scope)        { base::DefinedMultipleTimes::DifferentLines        }
        let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
        let(:method_line)  { 24                                                }
        let(:method_arity) { 1                                                 }

        it_should_behave_like 'a method matcher'
      end

      context 'on the same line' do
        let(:scope)        { base::DefinedMultipleTimes::SameLineSameScope     }
        let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb') }
        let(:method_line)  { 29                                                }
        let(:method_arity) { 1                                                 }

        it_should_behave_like 'a method matcher'
      end

      context 'on the same line with different scope' do
        let(:scope)        { base::DefinedMultipleTimes::SameLineDifferentScope }
        let(:source_path)  { MutantSpec::ROOT.join('test_app/lib/test_app.rb')  }
        let(:method_line)  { 33                                                 }
        let(:method_arity) { 1                                                  }

        it_should_behave_like 'a method matcher'
      end

      context 'in module eval' do
        let(:scope) { base::InModuleEval }

        it 'does not emit matcher' do
          subject
          expect(yields.length).to be(0)
        end

        it 'does warn' do
          subject
          expect(reporter.warn_calls.last).to(
            eql("#{method.inspect} is defined from a 3rd party lib unable to emit subject")
          )
        end
      end

      context 'in class eval' do
        let(:scope) { base::InClassEval }

        it 'does not emit matcher' do
          subject
          expect(yields.length).to be(0)
        end

        it 'does warn' do
          subject
          expect(reporter.warn_calls.last).to(
            eql("#{method.inspect} is defined from a 3rd party lib unable to emit subject")
          )
        end
      end
    end
  end

  describe '.build' do
    let(:object) { described_class }

    subject { object.build(env, scope, method) }

    let(:scope) do
      Class.new do
        include Adamantium

        def foo
        end
        memoize :foo

        def bar
        end
      end
    end

    let(:method) do
      scope.instance_method(method_name)
    end

    context 'with adamantium infected scope' do
      context 'with unmemoized method' do
        let(:method_name) { :bar }

        it { should eql(described_class.new(env, scope, method)) }
      end

      context 'with memoized method' do
        let(:method_name) { :foo }

        it { should eql(described_class::Memoized.new(env, scope, method)) }
      end
    end
  end
end
