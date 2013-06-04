require 'spec_helper'

describe Mutant::Matcher::Method::Singleton, '#each' do
  let(:object) { described_class.new(scope, method) }
  let(:method) { scope.method(method_name) }

  let(:yields) { [] }

  let(:namespace) do 
    klass = self.class
  end

  let(:scope) { self.class::Foo }

  subject { object.each { |subject| yields << subject } }

  let(:type)         { :defs }
  let(:method_arity) { 0     }

  def name
    node.children[1]
  end

  def arguments
    node.children[2]
  end

  context 'on singleton methods' do

    context 'when defined on self' do
      let(:base) { __LINE__ }
      class self::Foo
        def self.bar; end
      end

      let(:method_name) { :bar }
      let(:method_line) { 2    }

      it_should_behave_like 'a method matcher'
    end

    context 'when defined on constant' do

      context 'inside namespace' do
        let(:base) { __LINE__ }
        module self::Namespace
          class Foo
            def Foo.bar; end
          end
        end

        let(:scope)       { self.class::Namespace::Foo }
        let(:method_name) { :bar                       }
        let(:method_line) { 3                          }

        it_should_behave_like 'a method matcher'
      end

      context 'outside namespace' do
        let(:base) { __LINE__ }
        module self::Namespace
          class Foo; end;
          def Foo.bar; end
        end

        let(:method_name) { :bar }
        let(:method_line) { 3    }
        let(:scope)       { self.class::Namespace::Foo }

        it_should_behave_like 'a method matcher'
      end
    end

    context 'when defined multiple times in the same line' do
      context 'with method on differend scope' do
        let(:base) { __LINE__ }
        module self::Namespace
          module Foo; end
          module Bar
            def self.baz; end; def Foo.baz(arg); end
          end
        end

        let(:scope)        { self.class::Namespace::Bar }
        let(:method_name)  { :baz                       }
        let(:method_line)  { 4                          }
        let(:method_arity) { 0                          }

        it_should_behave_like 'a method matcher'
      end
    end
  end
end
