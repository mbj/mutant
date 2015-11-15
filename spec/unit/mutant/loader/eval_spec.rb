RSpec.describe Mutant::Loader::Eval, '.call' do

  subject { object.call(node, mutation_subject) }

  let(:object) { Class.new(described_class) }
  let(:path)   { __FILE__        }
  let(:line)   { 1               }

  let(:mutation_subject) do
    instance_double(Mutant::Subject, source_path: path, source_line: line)
  end

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
    expect(::SomeNamespace::Bar
      .instance_method(:some_method)
      .source_location).to eql([__FILE__, 3])
  end
end
