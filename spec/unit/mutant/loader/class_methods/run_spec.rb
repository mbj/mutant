require 'spec_helper'

describe Mutant::Loader, '.run' do
  subject { object.run(node) }

  let(:object) { described_class }

  after do
    Object.send(:remove_const, :SomeNamespace)
  end

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
    Rubinius::AST::Script.new(source.to_ast).tap do |source|
      source.file = "/some/source"
    end
  end

  it 'should load nodes into vm' do
    subject
    SomeNamespace::SomeOther::Foo
  end
end
