# frozen_string_literal: true

RSpec.describe Mutant::Context do
  let(:object) do
    described_class.new(
      constant_scope:,
      scope:,
      source_path:
    )
  end

  let(:source_path) { instance_double(Pathname) }

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        TestApp::Literal
    )
  end

  let(:constant_scope) do
    described_class::ConstantScope::Module.new(
      const:      s(:const, nil, :TestApp),
      descendant: described_class::ConstantScope::Class.new(
        const:      s(:const, nil, :Literal),
        descendant: described_class::ConstantScope::None.new
      )
    )
  end

  describe '#identification' do
    subject { object.identification }

    it { is_expected.to eql(scope.raw.name) }
  end

  describe '#root' do
    subject { object.root(node) }

    let(:generated_source) do
      Unparser.unparse(subject)
    end

    let(:node) { s(:sym, :node) }

    context 'nested in module' do
      let(:expected_source) do
        generate(parse(<<-RUBY))
          module TestApp
            class Literal
              :node
            end
          end
        RUBY
      end

      it 'should create correct source' do
        expect(generated_source).to eql(expected_source)
      end
    end

    context 'nested in class' do
      let(:constant_scope) do
        described_class::ConstantScope::Class.new(
          const:      s(:const, nil, :TestApp),
          descendant: described_class::ConstantScope::Module.new(
            const:      s(:const, nil, :Literal),
            descendant: described_class::ConstantScope::None.new
          )
        )
      end

      let(:expected_source) do
        generate(parse(<<-RUBY))
          class TestApp
            module Literal
              :node
            end
          end
        RUBY
      end

      it 'should create correct source' do
        expect(generated_source).to eql(expected_source)
      end
    end

    context 'flat' do
      let(:constant_scope) do
        described_class::ConstantScope::Class.new(
          const:      s(:const, s(:const, nil, :TestApp), :Literal),
          descendant: described_class::ConstantScope::None.new
        )
      end

      let(:expected_source) do
        generate(parse(<<~RUBY))
          class TestApp::Literal
            :node
          end
        RUBY
      end

      it 'should create correct source' do
        expect(generated_source).to eql(expected_source)
      end
    end
  end

  describe '#match_expressions' do
    subject { object.match_expressions }

    context 'on toplevel scope' do
      let(:scope) do
        Mutant::Scope.new(
          expression: instance_double(Mutant::Expression),
          raw:        TestApp
        )
      end

      it { is_expected.to eql([parse_expression('TestApp*')]) }
    end

    context 'on nested scope' do
      specify do
        is_expected.to eql(
          [
            parse_expression('TestApp::Literal*'),
            parse_expression('TestApp*')
          ]
        )
      end
    end
  end
end
