require 'spec_helper'

describe Mutant, 'method matching' do
  after do
    if defined?(::Foo)
      Object.send(:remove_const, 'Foo')
    end
  end

  before do
    eval(body)
    File.stub(:read => body)
  end

  let(:defaults) { {} }

  context 'on instance methods' do
    let(:pattern) { 'Foo#bar' }
    let(:defaults) do
      {
        :constant     => Foo,
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

      it_should_behave_like 'a method match'
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

        it_should_behave_like 'a method match'
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

        it_should_behave_like 'a method match'
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

        it_should_behave_like 'a method match'
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
              :constant => Foo::Bar
            }
          end

          it_should_behave_like 'a method match'
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
              :constant => Foo::Bar
            }
          end

          it_should_behave_like 'a method match'
        end
      end
    end
  end

  context 'on singleton methods' do
    let(:pattern) { 'Foo.bar' }
    let(:defaults) do
      {
        :constant     => Foo,
        :node_class   => Rubinius::AST::DefineSingletonScope,
        :method_arity => 0
      }
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

      it_should_behave_like 'a method match'
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

        it_should_behave_like 'a method match'
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

        it_should_behave_like 'a method match'
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
            :constant     => Bar,
            :method_name  => :baz,
            :method_line  => 4,
            :method_arity => 0
          }
        end

        it_should_behave_like 'a method match'
      end
    end
  end
end
