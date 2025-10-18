# frozen_string_literal: true

RSpec.describe Mutant::Mutation do
  let(:mutation_class) do
    Class.new(Mutant::Mutation) do
      const_set(:SYMBOL, 'test')
      const_set(:TEST_PASS_SUCCESS, true)
    end
  end

  let(:context)   { instance_double(Mutant::Context) }
  let(:kernel)    { instance_double(Kernel)          }
  let(:node)      { s(:nil)                          }
  let(:root_node) { s(:int, 1)                       }

  let(:object) do
    mutation_class.from_node(subject: mutation_subject, node:).from_right
  end

  let(:mutation_subject) do
    instance_double(
      Mutant::Subject,
      identification: 'subject',
      context:,
      source:         'original'
    )
  end

  before do
    allow(context).to receive(:root)
      .with(node)
      .and_return(root_node)
  end

  describe '.from_node' do
    def apply
      mutation_class.from_node(subject: mutation_subject, node:)
    end

    before do
      allow(Unparser).to receive(:unparse_validate_ast_either).and_return(result)
    end

    context 'on passing validation' do
      let(:result) { right('nil') }

      it 'validates correct ast' do
        apply

        expect(Unparser)
          .to have_received(:unparse_validate_ast_either)
          .with(ast: Unparser::AST.from_node(node:))
      end

      it 'returns expected mutation' do
        expect(apply).to eql(
          right(
            mutation_class.new(
              subject: mutation_subject,
              node:    s(:nil),
              source:  'nil'
            )
          )
        )
      end
    end

    context 'on failing validation' do
      let(:result) { left(unparser_validation) }

      let(:unparser_validation) { instance_double(Unparser::Validation) }

      it 'validates correct ast' do
        apply

        expect(Unparser)
          .to have_received(:unparse_validate_ast_either)
          .with(ast: Unparser::AST.from_node(node:))
      end

      it 'returns expected mutation' do
        expect(apply).to eql(
          left(
            described_class::GenerationError.new(
              node:,
              subject:             mutation_subject,
              unparser_validation:
            )
          )
        )
      end
    end
  end

  describe '#subject' do
    subject { object.subject }

    it { should be(subject) }
  end

  describe '#node' do
    subject { object.node }

    it { should be(node) }
  end

  describe '#insert' do
    subject { object }

    def apply
      subject.insert(kernel)
    end

    before do
      allow(mutation_subject).to receive(:prepare)
        .and_return(mutation_subject)

      allow(mutation_subject).to receive(:post_insert)
        .and_return(mutation_subject)

      allow(Mutant::Loader).to receive(:call)
        .and_return(loader_result)
    end

    let(:expected_source) { '1' }

    context 'on successful loader result' do
      let(:loader_result) { Mutant::Loader::SUCCESS }

      it 'performs insertion with cleanup' do
        apply

        expect(mutation_subject).to have_received(:prepare).ordered

        expect(Mutant::Loader).to have_received(:call)
          .ordered
          .with(
            binding: TOPLEVEL_BINDING,
            kernel:,
            source:  expected_source,
            subject: mutation_subject
          )

        expect(mutation_subject).to have_received(:post_insert).ordered
      end

      it 'returns loader result' do
        expect(apply).to eql(loader_result)
      end
    end

    context 'on failed loader result' do
      let(:loader_result) { Mutant::Loader::VOID_VALUE }

      it 'does perform insertion without cleanup' do
        apply

        expect(mutation_subject).to have_received(:prepare).ordered

        expect(Mutant::Loader).to have_received(:call)
          .ordered
          .with(
            binding: TOPLEVEL_BINDING,
            kernel:,
            source:  expected_source,
            subject: mutation_subject
          )

        expect(mutation_subject).to_not have_received(:post_insert)
      end

      it 'returns loader result' do
        expect(apply).to eql(loader_result)
      end
    end
  end

  describe '#code' do
    subject { object.code }

    it { should eql('8771a') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#original_source' do
    subject { object.original_source }

    it { should eql('original') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql('nil') }

    it_should_behave_like 'an idempotent method'
  end

  describe '.success?' do
    subject { mutation_class.success?(test_result) }

    let(:test_result) do
      instance_double(
        Mutant::Result::Test,
        passed:
      )
    end

    context 'on mutation with positive pass expectation' do
      context 'when Result::Test#passed equals expectation' do
        let(:passed) { true }

        it { should be(true) }
      end

      context 'when Result::Test#passed NOT equals expectation' do
        let(:passed) { false }

        it { should be(false) }
      end
    end

    context 'on mutation with negative pass expectation' do
      let(:mutation_class) do
        Class.new(super()) do
          const_set(:TEST_PASS_SUCCESS, false)
        end
      end

      context 'when Result::Test#passed equals expectation' do
        let(:passed) { true }

        it { should be(false) }
      end

      context 'when Result::Test#passed NOT equals expectation' do
        let(:passed) { false }

        it { should be(true) }
      end
    end
  end

  describe '#diff' do
    def apply
      object.diff
    end

    it 'returns expected diff' do
      expect(apply).to eql(
        Unparser::Diff.new(%w[original], %w[nil])
      )
    end
  end

  describe '#identification' do

    subject { object.identification }

    it { should eql('test:subject:8771a') }

    it_should_behave_like 'an idempotent method'
  end
end
