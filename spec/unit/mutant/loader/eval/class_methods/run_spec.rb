require 'spec_helper'

describe Mutant::Loader::Eval, '.run' do

  subject { object.run(node, file, line) }

  let(:object) { described_class }
  let(:file)   { 'test.rb'       }
  let(:line)   { 1               }

  let(:source) do
    # This test case will blow up when not executed
    # under toplevel binding.
    <<-RUBY
      class SomeNamespace
        class Bar
          def some_method
          end
        end

        class SomeOther
          class Foo < Bar
          end
        end
      end
    RUBY
  end

  let(:node) do
    source.to_ast
  end

  it 'should load nodes into vm' do
    subject
    ::SomeNamespace::SomeOther::Foo
  end

  it 'should set file and line correctly' do
    subject
    ::SomeNamespace::Bar.instance_method(:some_method).source_location.should eql(['test.rb', 3])
  end
end
