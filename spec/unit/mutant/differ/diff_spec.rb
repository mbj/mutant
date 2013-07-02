require 'spec_helper'

describe Mutant::Differ, '#diff' do
  let(:object) { described_class.new(old, new) }

  subject { object.diff }

  context 'when there is a diff at beginning of hunk' do
    let(:old) { %w(foo bar) }
    let(:new) { %w(baz bar) }

    it { should eql("@@ -1,3 +1,3 @@\n-foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is a diff NOT at beginning of hunk' do
    let(:old) { %w(foo bar) }
    let(:new) { %w(foo baz bar) }

    it { should eql("@@ -1,3 +1,4 @@\n foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is no diff' do
    let(:old) { '' }
    let(:new) { '' }

    it { should be(nil) }

    it_should_behave_like 'an idempotent method'
  end
end
