shared_examples_for 'a method matcher' do
  before do
    subject
  end

  let(:node)              { mutation_subject.node    }
  let(:context)           { mutation_subject.context }
  let(:mutation_subject)  { yields.first   }

  it 'should return one subject' do
    yields.size.should be(1)
  end

  it_should_behave_like 'an #each method'

  it 'should have correct method name' do
    name.should eql(method_name)
  end

  it 'should have correct line number' do
    (node.line - base).should eql(method_line)
  end

  it 'should have correct arity' do
    arguments.required.length.should eql(method_arity)
  end

  it 'should have correct scope in context' do
    context.send(:scope).should eql(scope)
  end

  it 'should have the correct node class' do
    node.should be_a(node_class)
  end
end
