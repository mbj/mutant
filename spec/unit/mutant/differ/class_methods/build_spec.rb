require 'spec_helper'

describe Mutant::Differ, '.build' do
  let(:object) { described_class }

  subject { object.build(old_string, new_string) }

  let(:old_string) { "foo\nbar" }
  let(:new_string) { "bar\nbaz" }

  it { should eql(Mutant::Differ.new(%w(foo bar), %w(bar baz))) }
end
