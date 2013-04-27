require 'spec_helper'

describe Mutant::Matcher::Method::Instance, '#each' do
  let(:object) { described_class.new(scope, method) }
  let(:method) { scope.instance_method(method_name) }

  let(:yields) { [] }

  let(:namespace) do 
    klass = self.class
  end

  let(:scope) { self.class::Foo }

  subject { object.each { |subject| yields << subject } }

  shared_examples_for 'a method match' do
    before do
      subject
    end

    let(:node)              { mutation_subject.node    }
    let(:context)           { mutation_subject.context }
    let(:mutation_subject)  { yields.first   }

    it 'should return one subject' do
      yields.size.should be(1)
    end

    it 'should have correct method name' do
      node.name.should eql(method_name)
    end

    it 'should have correct line number' do
      (node.line - base).should eql(method_line)
    end

    it 'should have correct arity' do
      node.arguments.required.length.should eql(method_arity)
    end

    it 'should have correct scope in context' do
      context.send(:scope).should eql(scope)
    end

    it 'should have the correct node class' do
      node.should be_a(node_class)
    end
  end

  let(:node_class)   { Rubinius::AST::Define }
  let(:method_name)  { :bar                  }
  let(:method_arity) { 0                     }

  context 'when method is defined once' do
    let(:base) { __LINE__ }
    class self::Foo
      def bar; end
    end

    let(:method_line) { 2 }

    it_should_behave_like 'a method match'
  end

  context 'when method is defined multiple times' do
    context 'on differend lines' do
      let(:base) { __LINE__ }
      class self::Foo
        def bar; end
        def bar(arg); end
      end

      let(:method_line)  { 3 }
      let(:method_arity) { 1 }

      it_should_behave_like 'a method match'
    end

    context 'on the same line' do
      let(:base) { __LINE__ }
      class self::Foo
        def bar; end; def bar(arg); end
      end
    
      let(:method_line)  { 2 }
      let(:method_arity) { 1 }

      it_should_behave_like 'a method match'
    end

    context 'on the same line with differend scope' do
      let(:base) { __LINE__ }
      class self::Foo
        def self.bar; end; def bar(arg); end
      end

      let(:method_line) { 2 }
      let(:method_arity) { 1 }

      it_should_behave_like 'a method match'
    end

    context 'when nested' do
      let(:pattern) { 'Foo::Bar#baz' }

      context 'in class' do
        let(:base) { __LINE__ }
        class self::Foo
          class Bar
            def baz; end
          end
        end

        let(:method_line) { 3 }
        let(:method_name) { :baz }
        let(:scope)       { self.class::Foo::Bar }

        it_should_behave_like 'a method match'
      end

      context 'in module' do
        let(:base) { __LINE__ }
        module self::Foo
          class Bar
            def baz; end
          end
        end

        let(:method_line) { 3 }
        let(:method_name) { :baz }
        let(:scope)       { self.class::Foo::Bar }

        it_should_behave_like 'a method match'
      end
    end
  end
end
