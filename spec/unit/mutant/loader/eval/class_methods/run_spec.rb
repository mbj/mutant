require 'spec_helper'

describe Mutant::Loader::Eval, '.run' do

  subject { object.run(node) }

  let(:object) { described_class }

  let(:source) do
    # This test case will blow up when not executed
    # under toplevel binding.
    <<-RUBY
      class SomeNamespace
        class Bar
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
end
