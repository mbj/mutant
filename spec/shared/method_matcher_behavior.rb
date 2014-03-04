# encoding: utf-8

shared_examples_for 'a method matcher' do

  before { subject }

  let(:node)              { mutation_subject.node    }
  let(:context)           { mutation_subject.context }
  let(:mutation_subject)  { yields.first             }

  it 'should return one subject' do
    expect(yields.size).to be(1)
  end

  it_should_behave_like 'an #each method'

  it 'should have correct method name' do
    expect(name).to eql(method_name)
  end

  it 'should have correct line number' do
    expect(node.location.expression.line - base).to eql(method_line)
  end

  it 'should have correct arity' do
    expect(arguments.children.length).to eql(method_arity)
  end

  it 'should have correct scope in context' do
    expect(context.scope).to eql(scope)
  end

  it 'should have the correct node type' do
    expect(node.type).to be(type)
  end
end
