require 'spec_helper'

describe Mutant, 'method matching' do
  after do
    if defined?(::Foo)
      Object.send(:remove_const, 'Foo')
    end
  end

  this_example = 'Mutant method matching'

  shared_examples_for this_example do
    subject { p Mutant::Matcher::Method.parse(pattern).to_a }

    let(:values) { defaults.merge(expectation) }

    let(:method_name)       { values.fetch(:method_name)  }
    let(:method_line)       { values.fetch(:method_line)  }
    let(:method_arity)      { values.fetch(:method_arity) }
    let(:scope)             { values.fetch(:scope)        }
    let(:node_class)        { values.fetch(:node_class)   }
                           
    let(:node)              { mutation_subject.node    }
    let(:context)           { mutation_subject.context }
    let(:mutation_subject)  { subject.first   }

    it 'should return one subject' do
      subject.size.should be(1)
    end

    it 'should have correct method name' do
      name(node).should eql(method_name)
    end

    it 'should have correct line number' do
      node.line.should eql(method_line)
    end

    it 'should have correct arity' do
      arguments(node).required.length.should eql(method_arity)
    end

    it 'should have correct scope in context' do
      context.send(:scope).should eql(scope)
    end

    it 'should have the correct node class' do
      node.should be_a(node_class)
    end
  end

  before do
    #eval(body, TOPLEVEL_BINDING, __FILE__, 0)
    eval(body)
    File.stub(:read => body)
  end

  let(:defaults) { {} }

  context 'on instance methods' do
    def name(node)
      node.name
    end

    def arguments(node)
      node.arguments
    end

    let(:pattern) { 'Foo#bar' }
    let(:defaults) do
      {
        :scope        => Foo,
        :node_class   => Rubinius::AST::Define,
        :method_name  => :bar,
        :method_arity => 0
      }
    end

    context 'when method is defined once' do
      let(:body) do
        <<-RUBY
          class Foo
            def bar; end
          end
        RUBY
      end

      let(:expectation) do
        { :method_line  => 2 }
      end

      it_should_behave_like this_example
    end

    context 'when method is defined multiple times' do
      context 'on differend lines' do
        let(:body) do
          <<-RUBY
            class Foo
              def bar; end
              def bar(arg); end
            end
          RUBY
        end

        let(:expectation) do
          {
            :method_line  => 3,
            :method_arity => 1
          }
        end

        it_should_behave_like this_example
      end

      context 'on the same line' do
        let(:body) do
          <<-RUBY
            class Foo
              def bar; end; def bar(arg); end
            end
          RUBY
        end

        let(:expectation) do
          {
            :method_line  => 2,
            :method_arity => 1
          }
        end

        it_should_behave_like this_example
      end

      context 'on the same line with differend scope' do
        let(:body) do
          <<-RUBY
            class Foo
              def self.bar; end; def bar(arg); end
            end
          RUBY
        end

        let(:expectation) do
          {
            :method_line  => 2,
            :method_arity => 1
          }
        end

        it_should_behave_like this_example
      end

      context 'when nested' do
        let(:pattern) { 'Foo::Bar#baz' }

        context 'in class' do
          let(:body) do
            <<-RUBY
              class Foo
                class Bar
                  def baz; end
                end
              end
            RUBY
          end

          let(:expectation) do
            {
              :method_line => 3,
              :method_name => :baz,
              :scope    => Foo::Bar
            }
          end

          it_should_behave_like this_example
        end

        context 'in module' do
          let(:body) do
            <<-RUBY
              module Foo
                class Bar
                  def baz; end
                end
              end
            RUBY
          end

          let(:expectation) do
            {
              :method_line => 3,
              :method_name => :baz,
              :scope    => Foo::Bar
            }
          end

          it_should_behave_like this_example
        end
      end
    end
  end

  context 'on singleton methods' do
    let(:pattern) { 'Foo.bar' }
    let(:defaults) do
      {
        :scope        => Foo,
        :node_class   => Rubinius::AST::DefineSingleton,
        :method_arity => 0
      }
    end

    def name(node)
      node.body.name
    end

    def arguments(node)
      node.body.arguments
    end

    context 'when defined on self' do
      let(:body) do
        <<-RUBY
          class Foo
            def self.bar; end
          end
        RUBY
      end


      let(:expectation) do
        {
          :method_name  => :bar,
          :method_line  => 2,
        }
      end

      it_should_behave_like this_example
    end

    context 'when defined on constant' do

      context 'inside namespace' do
        let(:body) do
          <<-RUBY
            class Foo
              def Foo.bar; end
            end
          RUBY
        end


        let(:expectation) do
          {
            :method_name  => :bar,
            :method_line  => 2,
          }
        end

        it_should_behave_like this_example
      end

      context 'outside namespace' do
        let(:body) do
          <<-RUBY
            class Foo; end;
            def Foo.bar; end
          RUBY
        end


        let(:expectation) do
          {
            :method_name  => :bar,
            :method_line  => 2,
          }
        end

        it_should_behave_like this_example
      end
    end

    context 'when defined multiple times in the same line' do
      context 'with method on differend scope' do
        let(:body) do
          <<-RUBY
            module Foo; end

            module Bar
              def self.baz; end; def Foo.baz(arg); end
            end
          RUBY
        end

        let(:pattern) { 'Bar.baz' }

        let(:expectation) do
          {
            :scope        => Bar,
            :method_name  => :baz,
            :method_line  => 4,
            :method_arity => 0
          }
        end

        it_should_behave_like this_example
      end
    end
  end
end
