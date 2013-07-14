require 'spec_helper'

describe Mutant::Loader::Eval, '.run' do

  subject { object.run(node, mutation_subject) }

  let(:object)           { described_class                                               }
  let(:mutation_subject) { double('Subject', :source_path => path, :source_line => line) }
  let(:path)             { 'test.rb'                                                     }
  let(:line)             { 1                                                             }

  let(:source) do
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
    parse(source)
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
