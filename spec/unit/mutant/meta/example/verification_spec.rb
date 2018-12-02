# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example::Verification do
  let(:object) { described_class.new(example, mutations) }

  let(:example) do
    Mutant::Meta::Example.new(
      file:     'foo.rb',
      node:     s(:true),
      types:    [:true],
      expected: expected_nodes
    )
  end

  let(:mutations) do
    generated_nodes.map do |node|
      Mutant::Mutation::Evil.new(example, node)
    end
  end

  let(:generated_nodes) { [] }
  let(:expected_nodes)  { [] }

  describe '#success?' do
    subject { object.success? }

    context 'when generated nodes equal expected nodes' do
      it { should be(true) }
    end

    context 'when expected node is missing' do
      let(:expected_nodes) { [s(:false)] }

      it { should be(false) }
    end

    context 'when there is extra generated node' do
      let(:generated_nodes) { [s(:false)] }

      it { should be(false) }
    end

    context 'when there is no diff to original source' do
      let(:expected_nodes)  { [s(:true)] }
      let(:generated_nodes) { [s(:true)] }

      it { should be(false) }
    end
  end

  describe '#error_report' do
    subject { object.error_report }

    context 'on success' do
      specify do
        expect { subject }.to raise_error(
          RuntimeError,
          'no error report on successful validation'
        )
      end
    end

    context 'when expected node is missing' do
      let(:expected_nodes) { [s(:false), s(:nil)] }

      specify do
        should eql(<<~'REPORT')
          ---
          file: foo.rb
          original_ast: s(:true)
          original_source: 'true'
          missing:
          - node: s(:false)
            source: 'false'
          - node: s(:nil)
            source: nil
          unexpected: []
          invalid_syntax: []
          no_diff: []
        REPORT
      end
    end

    context 'when there is extra generated node' do
      let(:generated_nodes) { [s(:false), s(:nil)] }

      specify do
        should eql(<<~'REPORT')
          ---
          file: foo.rb
          original_ast: s(:true)
          original_source: 'true'
          missing: []
          unexpected:
          - node: s(:false)
            source: 'false'
          - node: s(:nil)
            source: nil
          invalid_syntax: []
          no_diff: []
        REPORT
      end
    end

    context 'when there is no diff to original source' do
      let(:expected_nodes)  { [s(:true)] }
      let(:generated_nodes) { [s(:true)] }

      specify do
        should eql(<<~'REPORT')
          ---
          file: foo.rb
          original_ast: s(:true)
          original_source: 'true'
          missing: []
          unexpected: []
          invalid_syntax: []
          no_diff:
          - node: s(:true)
            source: 'true'
        REPORT
      end
    end

    context 'when the generated node is invalid syntax after unparsed' do
      let(:invalid_node) do
        s(:op_asgn, s(:send, s(:self), :at, s(:int, 1)), :+, s(:int, 1))
      end

      let(:expected_nodes)  { [invalid_node] }
      let(:generated_nodes) { [invalid_node] }

      specify do
        should eql(<<~'REPORT')
          ---
          file: foo.rb
          original_ast: s(:true)
          original_source: 'true'
          missing: []
          unexpected: []
          invalid_syntax:
          - node: |-
              s(:op_asgn,
                s(:send,
                  s(:self), :at,
                  s(:int, 1)), :+,
                s(:int, 1))
            source: self.at(1) += 1
          no_diff: []
        REPORT
      end
    end
  end
end
