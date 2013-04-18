shared_examples_for 'a method match' do
  subject { Mutant::Matcher::Method.parse(pattern).to_a }

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
