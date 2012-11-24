shared_examples_for 'a mutator' do
  subject { object.each(node) { |item| yields << item } }

  let(:yields)        { []              }
  let(:object)        { described_class }

  unless instance_methods.map(&:to_s).include?('node')
    let(:node)          { source.to_ast   }
  end

  it_should_behave_like 'a command method'

  context 'with no block' do
    subject { object.each(node) }

    it { should be_instance_of(to_enum.class) }

    let(:expected_mutations)  do
      mutations.map do |mutation|
        if mutation.respond_to?(:to_ast)
          mutation.to_ast.to_sexp
        else
          mutation
        end
      end.to_set
    end

    it 'generates the expected mutations' do
      subject = self.subject.map(&:to_sexp).to_set

      unless subject == expected_mutations
        message = "Missing mutations: %s\nUnexpected mutations: %s" %
         [expected_mutations - subject, subject - expected_mutations ].map(&:to_a).map(&:inspect)
        fail message
      end
    end
  end
end

shared_examples_for 'a noop mutator' do
  let(:mutations) { [] }

  it_should_behave_like 'a mutator'
end
