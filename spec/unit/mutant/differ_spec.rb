# encoding: utf-8

require 'spec_helper'

describe Mutant::Differ do
  let(:object) { described_class }

  describe '.build' do

    subject { object.build(old_string, new_string) }

    let(:old_string) { "foo\nbar" }
    let(:new_string) { "bar\nbaz" }

    it { should eql(Mutant::Differ.new(%w(foo bar), %w(bar baz))) }

  end

  describe '.colorize_line' do
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
end
