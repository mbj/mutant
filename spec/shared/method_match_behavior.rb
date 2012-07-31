shared_examples_for 'a method match' do
  subject { Mutant::Matcher::Method.parse(pattern).to_a }

  let(:values) { defaults.merge(expectation) }

  let(:method_name)  { values.fetch(:method_name)  }
  let(:method_line)  { values.fetch(:method_line)  }
  let(:method_arity) { values.fetch(:method_arity) }
  let(:constant)     { values.fetch(:constant)     }
  let(:node_class)   { values.fetch(:node_class)   }

  let(:node)         { mutatee.node    }
  let(:context)      { mutatee.context }
  let(:mutatee)      { subject.first   }

  it 'should return one mutatee' do
    subject.size.should be(1)
  end

  it 'should have correct method name' do
    node.name.should eql(method_name)
  end

  it 'should have correct line number' do
    node.line.should eql(method_line)
  end

  it 'should have correct arity' do
    node.arguments.required.length.should eql(method_arity)
  end

  it 'should have correct constant in context' do
    context.send(:constant).should eql(constant)
  end

  it 'should have the correct node class' do
    node.should be_a(node_class)
  end
end
