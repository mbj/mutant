# frozen_string_literal: true

RSpec.shared_examples_for 'a method matcher' do
  let(:node)              { mutation_subject.node    }
  let(:context)           { mutation_subject.context }
  let(:mutation_subject)  { subject.first            }

  it 'returns one subject' do
    expect(subject.size).to be(1)
  end

  it 'has expected method name' do
    expect(name).to eql(method_name)
  end

  it 'has expected line number' do
    expect(node.location.expression.line).to eql(method_line)
  end

  it 'has expected arity' do
    expect(arguments.children.length).to eql(method_arity)
  end

  it 'has expected scope in context' do
    expect(context.scope).to eql(scope)
  end

  it 'has source path in context' do
    expect(context.source_path).to eql(source_path)
  end

  it 'has the correct node type' do
    expect(node.type).to be(type)
  end
end

RSpec.shared_examples_for 'skipped candidate' do
  before do
    expected_warnings.each do |warning|
      expect(env).to receive(:warn).with(warning).and_return(env)
    end
  end

  it 'does not emit matcher' do
    expect(subject).to eql([])
  end
end
