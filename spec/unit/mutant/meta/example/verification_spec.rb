# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example::Verification do
  let(:object)          { described_class.new(example:, mutations:) }
  let(:original_source) { 'true' }

  let(:location) do
    instance_double(
      Thread::Backtrace::Location,
      path: 'foo.rb',
      to_s: '<location>'
    )
  end

  let(:example) do
    Mutant::Meta::Example.new(
      expected:,
      location:,
      lvars:           [],
      node:            s(:true),
      operators:       Mutant::Mutation::Operators::Full.new,
      original_source:,
      types:           [:true]
    )
  end

  let(:mutations) do
    generated_nodes.map do |node|
      Mutant::Mutation::Evil.new(subject: example, node:)
    end
  end

  let(:generated_nodes) { [] }
  let(:expected)        { [] }

  def make_expected(input)
    Mutant::Meta::Example::Expected.new(
      node:            Unparser.parse(input),
      original_source: input
    )
  end

  context 'when generated nodes equal expected nodes' do
    it 'returns success' do
      expect(object.success?).to be(true)
    end

    it 'returns empty error report' do
      expect(object.error_report).to eql(<<~'REPORT'.chomp)
        <location>
        Original: (operators: full)
        (true)
        true
      REPORT
    end
  end

  shared_examples_for 'failure' do
    it 'returns failure' do
      expect(object.success?).to be(false)
    end

    it 'returns expected error report' do
      expect(object.error_report).to eql(expected_report)
    end
  end

  context 'when original source fails the unparser validation' do
    let(:expected_report) do
      <<~REPORT.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        [original] report
        [original] lines
      REPORT
    end

    let(:validation) do
      instance_double(Unparser::Validation, success?: false, report: "report\nlines")
    end

    before do
      allow(Unparser::Validation).to receive_messages(from_string: validation)
    end

    include_examples 'failure'
  end

  context 'when expected node is missing' do
    let(:expected)        { [make_expected('false'), make_expected('nil')] }
    let(:generated_nodes) { [s(:false)]                                    }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        Missing mutations:
        s(:nil)
        nil
      REPORT
    end

    include_examples 'failure'
  end

  context 'when there is unexpected generated node' do
    let(:expected)        { [make_expected('false')] }
    let(:generated_nodes) { [s(:false), s(:nil)] }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        Unexpected mutations:
        s(:nil)
        nil
      REPORT
    end

    include_examples 'failure'
  end

  context 'when mutation generates is no diff to original source' do
    let(:expected)        { [make_expected('true')] }
    let(:generated_nodes) { [s(:true)]              }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        No-Diff mutations:
        s(:true)
        true
      REPORT
    end

    include_examples 'failure'
  end

  context 'when the mutation is invalid' do
    let(:invalid_node) do
      s(:op_asgn, s(:send, s(:self), :at, s(:int, 1)), :+, s(:int, 1))
    end

    let(:generated_nodes) { [invalid_node] }

    let(:expected) do
      [
        Mutant::Meta::Example::Expected.new(
          node:            invalid_node,
          original_source: 'self.at(1) += 1'
        )
      ]
    end

    let(:expected_report) do
      <<~REPORT.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        [invalid-mutation] report
        [invalid-mutation] lines
      REPORT
    end

    let(:validation) do
      instance_double(Unparser::Validation, success?: false, report: "report\nlines")
    end

    before do
      allow(Unparser::Validation).to receive_messages(from_node: validation)
    end

    include_examples 'failure'

    it 'genrates validation with expected node' do
      object.success?

      expect(Unparser::Validation).to have_received(:from_node).with(invalid_node)
    end
  end
end
