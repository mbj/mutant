require 'spec_helper'

describe Mutant::Differ, '.colorize_line' do
  let(:object) { described_class }

  subject { object.colorize_line(line) }

  context 'line beginning with "+"' do
    let(:line) { '+line' }
    it { should eql(Mutant::Color::GREEN.format(line)) }
  end

  context 'line beginning with "-"' do
    let(:line) { '-line' }
    it { should eql(Mutant::Color::RED.format(line)) }
  end

  context 'line beginning in other char' do
    let(:line) { ' line' }
    it { should eql(line) }
  end
end
