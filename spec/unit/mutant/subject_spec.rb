# encoding: utf-8

require 'spec_helper'

describe Mutant::Subject do
  let(:class_under_test) do
    Class.new(described_class) do
      def match_expression
        'match'
      end
    end
  end

  let(:object) { class_under_test.new(context, node) }

  let(:node) do
    double('Node', location: location)
  end

  let(:location) do
    double('Location', expression: expression)
  end

  let(:expression) do
    double('Expression', line: 'source_line')
  end

  let(:context) do
    double(
      'Context',
      source_path: 'source_path',
      source_line: 'source_line'
    )
  end

  describe '#identification' do
    subject { object.identification }

    it { should eql('match:source_path:source_line') }
  end
end
