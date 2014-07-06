require 'spec_helper'

# rubocop:disable ClassAndModuleChildren
describe Mutant::Matcher::Method::Instance do

  let(:env)      { Fixtures::TEST_ENV             }
  let(:reporter) { Fixtures::TEST_CONFIG.reporter }

  describe '#each' do
    subject { object.each { |subject| yields << subject } }

    let(:object)       { described_class.build(env, scope, method) }
    let(:method)       { scope.instance_method(method_name)        }
    let(:yields)       { []                                        }
    let(:namespace)    { self.class                                }
    let(:scope)        { self.class::Foo                           }
    let(:type)         { :def                                      }
    let(:method_name)  { :bar                                      }
    let(:method_arity) { 0                                         }

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
        expect(reporter.warn_calls.last).to eql("#{method.inspect} does not have valid source location unable to emit matcher")
      end
    end

    context 'when method is defined once' do
      let(:base) { __LINE__ }
      class self::Foo
        def bar; end
      end

      let(:method_line) { 2 }

      it_should_behave_like 'a method matcher'
    end

    context 'when method is defined once with a memoizer' do
      let(:base) { __LINE__ }
      class self::Foo
        def bar; end
        include Adamantium
        memoize :bar
      end

      let(:method_line) { 2 }

      it_should_behave_like 'a method matcher'
    end

    context 'when method is defined multiple times' do
      context 'on differend lines' do
        let(:base) { __LINE__ }
        class self::Foo
          def bar
          end

          def bar(_arg)
          end
        end

        let(:method_line)  { 5 }
        let(:method_arity) { 1 }

        it_should_behave_like 'a method matcher'
      end

      context 'on the same line' do
        let(:base) { __LINE__ }
        class self::Foo
          def bar; end; def bar(_arg); end
        end

        let(:method_line)  { 2 }
        let(:method_arity) { 1 }

        it_should_behave_like 'a method matcher'
      end

      context 'on the same line with differend scope' do
        let(:base) { __LINE__ }
        class self::Foo
          def self.bar; end; def bar(_arg); end
        end

        let(:method_line)  { 2 }
        let(:method_arity) { 1 }

        it_should_behave_like 'a method matcher'
      end

      context 'when nested' do
        let(:pattern) { 'Foo::Bar#baz' }

        context 'in class' do
          let(:base) { __LINE__ }
          class self::Foo
            class Bar
              def baz
              end
            end
          end

          let(:method_line) { 3                    }
          let(:method_name) { :baz                 }
          let(:scope)       { self.class::Foo::Bar }

          it_should_behave_like 'a method matcher'
        end

        context 'in module' do
          let(:base) { __LINE__ }
          module self::Foo
            class Bar
              def baz
              end
            end
          end

          let(:method_line) { 3                    }
          let(:method_name) { :baz                 }
          let(:scope)       { self.class::Foo::Bar }

          it_should_behave_like 'a method matcher'
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
