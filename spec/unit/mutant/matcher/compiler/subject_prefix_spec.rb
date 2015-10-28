RSpec.describe Mutant::Matcher::Compiler::SubjectPrefix, '#call' do
  let(:object)   { described_class.new(parse_expression('Foo*')) }

  let(:_subject) do
    instance_double(
      Mutant::Subject,
      expression: parse_expression(subject_expression)
    )
  end

  subject { object.call(_subject) }

  context 'when subject expression is prefixed by expression' do
    let(:subject_expression) { 'Foo::Bar' }

    it { should be(true) }
  end

  context 'when subject expression is NOT prefixed by expression' do
    let(:subject_expression) { 'Bar' }

    it { should be(false) }
  end
end
